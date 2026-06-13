<#
.SYNOPSIS
Bootstraps AWS and GitHub prerequisites for Seera production deployment.

.DESCRIPTION
Creates the deploy prerequisites that can be automated safely:
Terraform state S3 bucket, GitHub Actions OIDC provider and role,
deployment IAM policy, ACM certificates, optional Route 53 DNS validation,
and GitHub Actions variables/secrets.

This script never creates or stores static AWS access keys. It uses the
currently authenticated AWS CLI identity and GitHub CLI session.
#>
[CmdletBinding()]
param(
    [string]$AwsRegion = "",
    [string]$BaseDomain = "",
    [string]$ApiDomain = "",
    [string]$FrontendDomain = "",
    [string]$AssetsDomain = "",
    [string]$GitHubRepo = "",
    [string]$GitHubBranch = "",
    [string]$HostedZoneId = "",
    [string]$TfStateBucket = "",
    [switch]$NoCustomDomain,
    [switch]$SkipStateBucketSetup,
    [switch]$SkipCertificateWait
)

$ErrorActionPreference = "Stop"

$RoleName = "github-seera-deploy"
$InlinePolicyName = "seera-prd-v7-deploy"
$OidcProviderUrl = "https://token.actions.githubusercontent.com"
$OidcAudience = "sts.amazonaws.com"
$AssetsCertificateRegion = "us-east-1"
$CloudFrontHostedZoneId = "Z2FDTNDATAQYW2"
$ManualDnsRecords = New-Object System.Collections.Generic.List[object]

function Read-Input {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [string]$Default = "",
        [switch]$Required
    )

    while ($true) {
        $suffix = if ([string]::IsNullOrWhiteSpace($Default)) { "" } else { " [$Default]" }
        $value = Read-Host "$Name$suffix"
        if ([string]::IsNullOrWhiteSpace($value)) {
            $value = $Default
        }
        if (-not $Required -or -not [string]::IsNullOrWhiteSpace($value)) {
            return $value.Trim()
        }
        Write-Host "$Name wajib diisi." -ForegroundColor Yellow
    }
}

function Test-CommandAvailable {
    param([Parameter(Mandatory = $true)][string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "CLI '$Name' tidak ditemukan di PATH. Install dan login terlebih dahulu."
    }
}

function ConvertTo-CommandLineArgument {
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Value)

    if ($Value.Length -eq 0) {
        return '""'
    }

    if ($Value -notmatch '[\s"]') {
        return $Value
    }

    $result = New-Object System.Text.StringBuilder
    [void]$result.Append('"')
    $backslashes = 0
    foreach ($char in $Value.ToCharArray()) {
        if ($char -eq '\') {
            $backslashes++
            continue
        }

        if ($char -eq '"') {
            [void]$result.Append(('\' * (($backslashes * 2) + 1)))
            [void]$result.Append('"')
            $backslashes = 0
            continue
        }

        if ($backslashes -gt 0) {
            [void]$result.Append(('\' * $backslashes))
            $backslashes = 0
        }
        [void]$result.Append($char)
    }

    if ($backslashes -gt 0) {
        [void]$result.Append(('\' * ($backslashes * 2)))
    }
    [void]$result.Append('"')
    return $result.ToString()
}

function Format-CliCommand {
    param(
        [Parameter(Mandatory = $true)][string]$File,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    $parts = @($File) + ($Arguments | ForEach-Object { ConvertTo-CommandLineArgument -Value $_ })
    return ($parts -join " ")
}

function Format-CliResult {
    param(
        [Parameter(Mandatory = $true)]$Result
    )

    $stdout = if ([string]::IsNullOrEmpty($Result.Stdout)) { "<empty>" } else { $Result.Stdout.TrimEnd() }
    $stderr = if ([string]::IsNullOrEmpty($Result.Stderr)) { "<empty>" } else { $Result.Stderr.TrimEnd() }
    return @(
        "Command: $($Result.Command)",
        "Exit code: $($Result.ExitCode)",
        "Stdout:",
        $stdout,
        "Stderr:",
        $stderr
    ) -join [Environment]::NewLine
}

function Invoke-CliResult {
    param(
        [Parameter(Mandatory = $true)][string]$File,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [string]$StandardInput = $null
    )

    $command = Format-CliCommand -File $File -Arguments $Arguments
    Write-Host "Running: $command" -ForegroundColor DarkGray

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $File
    $psi.Arguments = ($Arguments | ForEach-Object { ConvertTo-CommandLineArgument -Value $_ }) -join " "
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.RedirectStandardInput = $null -ne $StandardInput
    $psi.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi

    try {
        [void]$process.Start()
        if ($null -ne $StandardInput) {
            $process.StandardInput.Write($StandardInput)
            $process.StandardInput.Close()
        }
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        $process.WaitForExit()

        return [pscustomobject]@{
            Command  = $command
            ExitCode = $process.ExitCode
            Stdout   = $stdoutTask.Result
            Stderr   = $stderrTask.Result
        }
    }
    finally {
        $process.Dispose()
    }
}

function Invoke-Cli {
    param(
        [Parameter(Mandatory = $true)][string]$File,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [string]$StandardInput = $null
    )

    $result = Invoke-CliResult -File $File -Arguments $Arguments -StandardInput $StandardInput
    if ($result.ExitCode -ne 0) {
        throw (Format-CliResult -Result $result)
    }
    return $result.Stdout.Trim()
}

function Invoke-Aws {
    param([Parameter(Mandatory = $true)][string[]]$Arguments)
    return Invoke-Cli -File "aws" -Arguments $Arguments
}

function Invoke-AwsResult {
    param([Parameter(Mandatory = $true)][string[]]$Arguments)
    return Invoke-CliResult -File "aws" -Arguments $Arguments
}

function Invoke-Gh {
    param(
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [string]$StandardInput = $null
    )
    return Invoke-Cli -File "gh" -Arguments $Arguments -StandardInput $StandardInput
}

function Get-AwsCliFileArg {
    param([Parameter(Mandatory = $true)][string]$Path)

    $fullPath = [System.IO.Path]::GetFullPath($Path).Replace("\", "/")
    return "file://$fullPath"
}

function New-TempJsonFile {
    param([Parameter(Mandatory = $true)]$Object)

    $path = Join-Path ([System.IO.Path]::GetTempPath()) ("seera-bootstrap-" + [guid]::NewGuid().ToString("N") + ".json")
    $json = $Object | ConvertTo-Json -Depth 30
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($path, $json, $encoding)
    return $path
}

function Get-AwsAccountId {
    $accountId = Invoke-Aws -Arguments @(
        "sts", "get-caller-identity",
        "--query", "Account",
        "--output", "text"
    )
    $accountId = $accountId.Trim()
    if ($accountId -notmatch '^\d{12}$') {
        throw "Tidak bisa membaca AWS account ID valid dari aws sts get-caller-identity --query Account --output text. Output: '$accountId'"
    }
    return $accountId
}

function Test-AwsPermissionProbe {
    param(
        [string]$Region,
        [string]$ZoneId,
        [bool]$NoCustomDomainEnabled
    )

    Write-Host "Memvalidasi akses dasar AWS CLI..." -ForegroundColor Cyan
    [void](Invoke-Aws -Arguments @("iam", "list-open-id-connect-providers", "--output", "json"))
    [void](Invoke-Aws -Arguments @("iam", "get-account-authorization-details", "--filter", "Role", "--max-items", "1", "--output", "json"))
    [void](Invoke-Aws -Arguments @("s3api", "list-buckets", "--output", "json"))
    if (-not $NoCustomDomainEnabled) {
        [void](Invoke-Aws -Arguments @("acm", "list-certificates", "--region", $Region, "--output", "json"))
        [void](Invoke-Aws -Arguments @("acm", "list-certificates", "--region", $AssetsCertificateRegion, "--output", "json"))
    }
    if (-not [string]::IsNullOrWhiteSpace($ZoneId)) {
        [void](Invoke-Aws -Arguments @("route53", "get-hosted-zone", "--id", $ZoneId, "--output", "json"))
    }
}

function Ensure-TerraformStateBucket {
    param(
        [Parameter(Mandatory = $true)][string]$Bucket,
        [Parameter(Mandatory = $true)][string]$Region,
        [bool]$SkipSetup = $false
    )

    Write-Host "Memastikan S3 bucket Terraform state: $Bucket" -ForegroundColor Cyan

    $headResult = Invoke-AwsResult -Arguments @("s3api", "head-bucket", "--bucket", $Bucket)
    if ($headResult.ExitCode -eq 0) {
        Write-Host "Bucket sudah ada dan bisa diakses, reuse." -ForegroundColor Green
        if ($SkipSetup) {
            Write-Host "SkipStateBucketSetup aktif; hanya validasi head-bucket, tanpa create/put versioning/encryption/public access block." -ForegroundColor Yellow
            return
        }
    }
    else {
        if ($SkipSetup) {
            throw "SkipStateBucketSetup aktif, tetapi head-bucket gagal untuk '$Bucket'.$([Environment]::NewLine)$(Format-CliResult -Result $headResult)"
        }

        $headText = "$($headResult.Stdout)$($headResult.Stderr)"
        if ($headText -match "Forbidden|AccessDenied|403") {
            throw "Bucket '$Bucket' sudah ada tetapi tidak bisa diakses oleh akun ini. Pakai nama bucket lain via -TfStateBucket.$([Environment]::NewLine)$(Format-CliResult -Result $headResult)"
        }

        if ($Region -eq "us-east-1") {
            [void](Invoke-Aws -Arguments @("s3api", "create-bucket", "--bucket", $Bucket, "--region", $Region))
        }
        else {
            [void](Invoke-Aws -Arguments @(
                "s3api", "create-bucket",
                "--bucket", $Bucket,
                "--region", $Region,
                "--create-bucket-configuration", "LocationConstraint=$Region"
            ))
        }
        [void](Invoke-Aws -Arguments @("s3api", "wait", "bucket-exists", "--bucket", $Bucket))
        Write-Host "Bucket dibuat." -ForegroundColor Green
    }

    $publicAccessResult = Invoke-AwsResult -Arguments @(
        "s3api", "get-public-access-block",
        "--bucket", $Bucket,
        "--output", "json"
    )
    $publicAccessOk = $false
    if ($publicAccessResult.ExitCode -eq 0) {
        $publicAccess = $publicAccessResult.Stdout | ConvertFrom-Json
        $config = $publicAccess.PublicAccessBlockConfiguration
        $publicAccessOk = (
            $config.BlockPublicAcls -eq $true -and
            $config.IgnorePublicAcls -eq $true -and
            $config.BlockPublicPolicy -eq $true -and
            $config.RestrictPublicBuckets -eq $true
        )
    }
    if ($publicAccessOk) {
        Write-Host "S3 public access block sudah sesuai." -ForegroundColor Green
    }
    else {
        Write-Host "Mengaktifkan S3 public access block..." -ForegroundColor Cyan
        [void](Invoke-Aws -Arguments @(
            "s3api", "put-public-access-block",
            "--bucket", $Bucket,
            "--public-access-block-configuration",
            "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
        ))
    }

    $versioning = Invoke-Aws -Arguments @(
        "s3api", "get-bucket-versioning",
        "--bucket", $Bucket,
        "--output", "json"
    ) | ConvertFrom-Json
    if ($versioning.Status -eq "Enabled") {
        Write-Host "S3 bucket versioning sudah Enabled." -ForegroundColor Green
    }
    else {
        Write-Host "Mengaktifkan S3 bucket versioning..." -ForegroundColor Cyan
        [void](Invoke-Aws -Arguments @(
            "s3api", "put-bucket-versioning",
            "--bucket", $Bucket,
            "--versioning-configuration", "Status=Enabled"
        ))
    }

    $encryptionResult = Invoke-AwsResult -Arguments @(
        "s3api", "get-bucket-encryption",
        "--bucket", $Bucket,
        "--output", "json"
    )
    $encryptionOk = $false
    if ($encryptionResult.ExitCode -eq 0) {
        $encryption = $encryptionResult.Stdout | ConvertFrom-Json
        foreach ($rule in @($encryption.ServerSideEncryptionConfiguration.Rules)) {
            $algorithm = $rule.ApplyServerSideEncryptionByDefault.SSEAlgorithm
            if ($algorithm -in @("AES256", "aws:kms", "aws:kms:dsse")) {
                $encryptionOk = $true
            }
        }
    }
    if ($encryptionOk) {
        Write-Host "S3 server-side encryption sudah aktif." -ForegroundColor Green
    }
    else {
        Write-Host "Mengaktifkan S3 server-side encryption AES256..." -ForegroundColor Cyan
        $encryptionConfig = [ordered]@{
            Rules = @(
                [ordered]@{
                    ApplyServerSideEncryptionByDefault = [ordered]@{
                        SSEAlgorithm = "AES256"
                    }
                }
            )
        }
        $encryptionFile = New-TempJsonFile -Object $encryptionConfig
        try {
            [void](Invoke-Aws -Arguments @(
                "s3api", "put-bucket-encryption",
                "--bucket", $Bucket,
                "--server-side-encryption-configuration", (Get-AwsCliFileArg $encryptionFile)
            ))
        }
        finally {
            Remove-Item -LiteralPath $encryptionFile -Force -ErrorAction SilentlyContinue
        }
    }
}

function Ensure-GitHubOidcProvider {
    param([Parameter(Mandatory = $true)][string]$AccountId)

    if ($AccountId -notmatch '^\d{12}$') {
        throw "AccountId tidak valid untuk ARN OIDC provider: '$AccountId'"
    }

    $providerArn = "arn:aws:iam::{0}:oidc-provider/token.actions.githubusercontent.com" -f $AccountId

    Write-Host "Memastikan IAM OIDC provider GitHub: $providerArn" -ForegroundColor Cyan
    $existingResult = Invoke-AwsResult -Arguments @(
        "iam", "get-open-id-connect-provider",
        "--open-id-connect-provider-arn", $providerArn,
        "--output", "json"
    )
    if ($existingResult.ExitCode -ne 0) {
        if ("$($existingResult.Stdout)$($existingResult.Stderr)" -notmatch "NoSuchEntity|not found|NotFound") {
            throw (Format-CliResult -Result $existingResult)
        }
        $createArgs = @(
            "iam", "create-open-id-connect-provider",
            "--url", $OidcProviderUrl,
            "--client-id-list", $OidcAudience
        )
        [void](Invoke-Aws -Arguments $createArgs)
        Write-Host "OIDC provider dibuat." -ForegroundColor Green
    }
    else {
        Write-Host "OIDC provider sudah ada, reuse." -ForegroundColor Green
    }

    Write-Host "GitHub OIDC provider ARN final: $providerArn" -ForegroundColor Green
    return $providerArn
}

function Ensure-GitHubDeployRole {
    param(
        [Parameter(Mandatory = $true)][string]$AccountId,
        [Parameter(Mandatory = $true)][string]$ProviderArn,
        [Parameter(Mandatory = $true)][string]$Repo,
        [Parameter(Mandatory = $true)][string]$Branch,
        [Parameter(Mandatory = $true)][string]$StateBucket
    )

    $subject = "repo:$Repo`:ref:refs/heads/$Branch"
    $trustPolicy = [ordered]@{
        Version   = "2012-10-17"
        Statement = @(
            [ordered]@{
                Effect    = "Allow"
                Principal = [ordered]@{
                    Federated = $ProviderArn
                }
                Action    = "sts:AssumeRoleWithWebIdentity"
                Condition = [ordered]@{
                    StringEquals = [ordered]@{
                        "token.actions.githubusercontent.com:aud" = $OidcAudience
                        "token.actions.githubusercontent.com:sub" = $subject
                    }
                }
            }
        )
    }
    $trustFile = New-TempJsonFile -Object $trustPolicy

    Write-Host "Memastikan IAM role GitHub Actions: $RoleName" -ForegroundColor Cyan
    $roleResult = Invoke-AwsResult -Arguments @("iam", "get-role", "--role-name", $RoleName, "--output", "json")
    if ($roleResult.ExitCode -ne 0) {
        if ("$($roleResult.Stdout)$($roleResult.Stderr)" -notmatch "NoSuchEntity|not found|NotFound") {
            throw (Format-CliResult -Result $roleResult)
        }
        [void](Invoke-Aws -Arguments @(
            "iam", "create-role",
            "--role-name", $RoleName,
            "--description", "GitHub Actions OIDC deploy role for Seera PRD v7",
            "--assume-role-policy-document", (Get-AwsCliFileArg $trustFile)
        ))
        Write-Host "IAM role dibuat." -ForegroundColor Green
    }
    else {
        [void](Invoke-Aws -Arguments @(
            "iam", "update-assume-role-policy",
            "--role-name", $RoleName,
            "--policy-document", (Get-AwsCliFileArg $trustFile)
        ))
        Write-Host "IAM role sudah ada, trust policy di-update/reuse." -ForegroundColor Green
    }

    $stateBucketArn = "arn:aws:s3:::$StateBucket"
    $deploymentBucketArn = "arn:aws:s3:::seera-prod-*"
    $policy = [ordered]@{
        Version   = "2012-10-17"
        Statement = @(
            [ordered]@{
                Sid      = "TerraformStateBucket"
                Effect   = "Allow"
                Action   = @(
                    "s3:GetAccelerateConfiguration",
                    "s3:PutAccelerateConfiguration",
                    "s3:GetBucketAcl",
                    "s3:PutBucketAcl",
                    "s3:GetBucketCORS",
                    "s3:PutBucketCORS",
                    "s3:DeleteBucketCORS",
                    "s3:GetBucketLocation",
                    "s3:GetBucketTagging",
                    "s3:PutBucketTagging",
                    "s3:GetBucketPolicy",
                    "s3:GetBucketPolicyStatus",
                    "s3:PutBucketPolicy",
                    "s3:GetBucketVersioning",
                    "s3:PutBucketVersioning",
                    "s3:GetEncryptionConfiguration",
                    "s3:PutEncryptionConfiguration",
                    "s3:GetBucketPublicAccessBlock",
                    "s3:GetBucketWebsite",
                    "s3:PutBucketWebsite",
                    "s3:DeleteBucketWebsite",
                    "s3:GetBucketLogging",
                    "s3:PutBucketLogging",
                    "s3:GetBucketNotification",
                    "s3:PutBucketNotification",
                    "s3:GetBucketRequestPayment",
                    "s3:PutBucketRequestPayment",
                    "s3:GetReplicationConfiguration",
                    "s3:PutReplicationConfiguration",
                    "s3:DeleteReplicationConfiguration",
                    "s3:GetBucketOwnershipControls",
                    "s3:PutBucketOwnershipControls",
                    "s3:GetBucketObjectLockConfiguration",
                    "s3:PutBucketObjectLockConfiguration",
                    "s3:ListBucket",
                    "s3:PutBucketPublicAccessBlock",
                    "s3:GetLifecycleConfiguration",
                    "s3:PutLifecycleConfiguration"
                )
                Resource = @($stateBucketArn)
            },
            [ordered]@{
                Sid      = "TerraformStateObjects"
                Effect   = "Allow"
                Action   = @("s3:GetObject", "s3:PutObject", "s3:DeleteObject")
                Resource = @("$stateBucketArn/*")
            },
            [ordered]@{
                Sid      = "SeeraAssetBuckets"
                Effect   = "Allow"
                Action   = @(
                    "s3:CreateBucket",
                    "s3:DeleteBucket",
                    "s3:GetAccelerateConfiguration",
                    "s3:PutAccelerateConfiguration",
                    "s3:GetBucketAcl",
                    "s3:PutBucketAcl",
                    "s3:GetBucketCORS",
                    "s3:PutBucketCORS",
                    "s3:DeleteBucketCORS",
                    "s3:GetBucketLocation",
                    "s3:GetBucketTagging",
                    "s3:PutBucketTagging",
                    "s3:GetBucketPolicy",
                    "s3:GetBucketPolicyStatus",
                    "s3:PutBucketPolicy",
                    "s3:DeleteBucketPolicy",
                    "s3:GetBucketVersioning",
                    "s3:PutBucketVersioning",
                    "s3:GetEncryptionConfiguration",
                    "s3:PutEncryptionConfiguration",
                    "s3:GetBucketPublicAccessBlock",
                    "s3:PutBucketPublicAccessBlock",
                    "s3:GetBucketOwnershipControls",
                    "s3:PutBucketOwnershipControls",
                    "s3:GetBucketObjectLockConfiguration",
                    "s3:PutBucketObjectLockConfiguration",
                    "s3:GetLifecycleConfiguration",
                    "s3:PutLifecycleConfiguration",
                    "s3:GetBucketWebsite",
                    "s3:PutBucketWebsite",
                    "s3:DeleteBucketWebsite",
                    "s3:GetBucketLogging",
                    "s3:PutBucketLogging",
                    "s3:GetBucketNotification",
                    "s3:PutBucketNotification",
                    "s3:GetBucketRequestPayment",
                    "s3:PutBucketRequestPayment",
                    "s3:GetReplicationConfiguration",
                    "s3:PutReplicationConfiguration",
                    "s3:DeleteReplicationConfiguration",
                    "s3:ListBucket",
                    "s3:GetObject",
                    "s3:PutObject",
                    "s3:DeleteObject"
                )
                Resource = @($deploymentBucketArn, "$deploymentBucketArn/*")
            },
            [ordered]@{
                Sid      = "S3Discovery"
                Effect   = "Allow"
                Action   = @("s3:ListAllMyBuckets", "s3:GetAccountPublicAccessBlock")
                Resource = "*"
            },
            [ordered]@{
                Sid      = "RegionalInfrastructure"
                Effect   = "Allow"
                Action   = @(
                    "ec2:*",
                    "ecs:*",
                    "ecr:*",
                    "elasticloadbalancing:*",
                    "rds:*",
                    "acm:*",
                    "secretsmanager:*",
                    "logs:*",
                    "cloudwatch:*",
                    "application-autoscaling:*",
                    "amplify:*",
                    "route53:*",
                    "cloudfront:*",
                    "sts:GetCallerIdentity"
                )
                Resource = "*"
            },
            [ordered]@{
                Sid      = "ManageSeeraIam"
                Effect   = "Allow"
                Action   = @(
                    "iam:GetRole",
                    "iam:CreateRole",
                    "iam:DeleteRole",
                    "iam:UpdateRole",
                    "iam:UpdateAssumeRolePolicy",
                    "iam:GetRolePolicy",
                    "iam:PutRolePolicy",
                    "iam:DeleteRolePolicy",
                    "iam:ListRolePolicies",
                    "iam:AttachRolePolicy",
                    "iam:DetachRolePolicy",
                    "iam:ListAttachedRolePolicies",
                    "iam:CreatePolicy",
                    "iam:DeletePolicy",
                    "iam:GetPolicy",
                    "iam:GetPolicyVersion",
                    "iam:CreatePolicyVersion",
                    "iam:DeletePolicyVersion",
                    "iam:ListPolicyVersions",
                    "iam:TagRole",
                    "iam:UntagRole",
                    "iam:TagPolicy",
                    "iam:UntagPolicy"
                )
                Resource = @(
                    "arn:aws:iam::$AccountId`:role/seera-prod-*",
                    "arn:aws:iam::$AccountId`:policy/seera-prod-*"
                )
            },
            [ordered]@{
                Sid      = "PassSeeraRoles"
                Effect   = "Allow"
                Action   = "iam:PassRole"
                Resource = "arn:aws:iam::$AccountId`:role/seera-prod-*"
                Condition = [ordered]@{
                    StringLike = [ordered]@{
                        "iam:PassedToService" = @(
                            "ecs-tasks.amazonaws.com",
                            "ecs.amazonaws.com",
                            "application-autoscaling.amazonaws.com"
                        )
                    }
                }
            },
            [ordered]@{
                Sid      = "CreateServiceLinkedRoles"
                Effect   = "Allow"
                Action   = "iam:CreateServiceLinkedRole"
                Resource = "*"
                Condition = [ordered]@{
                    StringLike = [ordered]@{
                        "iam:AWSServiceName" = @(
                            "ecs.amazonaws.com",
                            "ecs.application-autoscaling.amazonaws.com",
                            "elasticloadbalancing.amazonaws.com",
                            "rds.amazonaws.com",
                            "amplify.amazonaws.com"
                        )
                    }
                }
            }
        )
    }
    $policyFile = New-TempJsonFile -Object $policy
    [void](Invoke-Aws -Arguments @(
        "iam", "put-role-policy",
        "--role-name", $RoleName,
        "--policy-name", $InlinePolicyName,
        "--policy-document", (Get-AwsCliFileArg $policyFile)
    ))

    $roleJson = Invoke-Aws -Arguments @("iam", "get-role", "--role-name", $RoleName, "--output", "json") | ConvertFrom-Json
    return $roleJson.Role.Arn
}

function Get-OrRequestCertificate {
    param(
        [Parameter(Mandatory = $true)][string]$Domain,
        [Parameter(Mandatory = $true)][string]$Region
    )

    Write-Host "Memastikan ACM certificate untuk $Domain di $Region" -ForegroundColor Cyan
    $certificates = Invoke-Aws -Arguments @(
        "acm", "list-certificates",
        "--region", $Region,
        "--certificate-statuses", "PENDING_VALIDATION", "ISSUED",
        "--output", "json"
    ) | ConvertFrom-Json

    $match = @($certificates.CertificateSummaryList | Where-Object { $_.DomainName -eq $Domain } | Select-Object -First 1)
    if ($match.Count -gt 0) {
        Write-Host "Certificate sudah ada, reuse: $($match[0].CertificateArn)" -ForegroundColor Green
        return $match[0].CertificateArn
    }

    $token = (($Domain + $Region) -replace "[^A-Za-z0-9]", "")
    if ($token.Length -gt 32) {
        $token = $token.Substring(0, 32)
    }
    if ([string]::IsNullOrWhiteSpace($token)) {
        $token = "seera"
    }

    $arn = Invoke-Aws -Arguments @(
        "acm", "request-certificate",
        "--domain-name", $Domain,
        "--validation-method", "DNS",
        "--idempotency-token", $token,
        "--region", $Region,
        "--query", "CertificateArn",
        "--output", "text"
    )
    Write-Host "Certificate diminta: $arn" -ForegroundColor Green
    return $arn
}

function Get-CertificateValidationRecords {
    param(
        [Parameter(Mandatory = $true)][string]$CertificateArn,
        [Parameter(Mandatory = $true)][string]$Region
    )

    for ($attempt = 1; $attempt -le 12; $attempt++) {
        $description = Invoke-Aws -Arguments @(
            "acm", "describe-certificate",
            "--certificate-arn", $CertificateArn,
            "--region", $Region,
            "--output", "json"
        ) | ConvertFrom-Json

        $records = @()
        foreach ($option in @($description.Certificate.DomainValidationOptions)) {
            if ($option.ResourceRecord) {
                $records += [pscustomobject]@{
                    CertificateArn = $CertificateArn
                    Region         = $Region
                    DomainName     = $option.DomainName
                    Name           = $option.ResourceRecord.Name
                    Type           = $option.ResourceRecord.Type
                    Value          = $option.ResourceRecord.Value
                }
            }
        }

        if ($records.Count -gt 0) {
            return $records
        }
        Start-Sleep -Seconds 5
    }

    Write-Warning "DNS validation record untuk $CertificateArn belum tersedia dari ACM."
    return @()
}

function Upsert-Route53ValidationRecord {
    param(
        [Parameter(Mandatory = $true)][string]$ZoneId,
        [Parameter(Mandatory = $true)]$Record
    )

    $changeBatch = [ordered]@{
        Comment = "Seera ACM DNS validation"
        Changes = @(
            [ordered]@{
                Action = "UPSERT"
                ResourceRecordSet = [ordered]@{
                    Name            = $Record.Name
                    Type            = $Record.Type
                    TTL             = 300
                    ResourceRecords = @(
                        [ordered]@{
                            Value = $Record.Value
                        }
                    )
                }
            }
        )
    }
    $changeFile = New-TempJsonFile -Object $changeBatch
    [void](Invoke-Aws -Arguments @(
        "route53", "change-resource-record-sets",
        "--hosted-zone-id", $ZoneId,
        "--change-batch", (Get-AwsCliFileArg $changeFile)
    ))
}

function Upsert-Route53AliasRecord {
    param(
        [Parameter(Mandatory = $true)][string]$ZoneId,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$DnsName,
        [Parameter(Mandatory = $true)][string]$TargetHostedZoneId
    )

    $changeBatch = [ordered]@{
        Comment = "Seera application alias record"
        Changes = @(
            [ordered]@{
                Action = "UPSERT"
                ResourceRecordSet = [ordered]@{
                    Name = $Name
                    Type = "A"
                    AliasTarget = [ordered]@{
                        DNSName              = $DnsName
                        HostedZoneId         = $TargetHostedZoneId
                        EvaluateTargetHealth = $false
                    }
                }
            }
        )
    }
    $changeFile = New-TempJsonFile -Object $changeBatch
    [void](Invoke-Aws -Arguments @(
        "route53", "change-resource-record-sets",
        "--hosted-zone-id", $ZoneId,
        "--change-batch", (Get-AwsCliFileArg $changeFile)
    ))
}

function Try-UpsertExistingApplicationRecords {
    param(
        [string]$ZoneId,
        [string]$Region,
        [string]$Api,
        [string]$Assets
    )

    if ([string]::IsNullOrWhiteSpace($ZoneId)) {
        return
    }

    Write-Host "Mengecek target aplikasi yang sudah tersedia untuk DNS alias awal..." -ForegroundColor Cyan

    $albResult = Invoke-AwsResult -Arguments @(
        "elbv2", "describe-load-balancers",
        "--names", "seera-prod-api-alb",
        "--region", $Region,
        "--output", "json"
    )
    if ($albResult.ExitCode -eq 0) {
        $alb = ($albResult.Stdout | ConvertFrom-Json).LoadBalancers | Select-Object -First 1
        if ($alb) {
            Write-Host "UPSERT API alias: $Api -> $($alb.DNSName)" -ForegroundColor Cyan
            Upsert-Route53AliasRecord -ZoneId $ZoneId -Name $Api -DnsName $alb.DNSName -TargetHostedZoneId $alb.CanonicalHostedZoneId
        }
    }
    else {
        Write-Host "API ALB belum tersedia; record $Api akan dibuat setelah Terraform/deploy menghasilkan target." -ForegroundColor Yellow
        Write-Host (Format-CliResult -Result $albResult) -ForegroundColor DarkGray
    }

    $distributionResult = Invoke-AwsResult -Arguments @("cloudfront", "list-distributions", "--output", "json")
    if ($distributionResult.ExitCode -eq 0) {
        $distributions = @((($distributionResult.Stdout | ConvertFrom-Json).DistributionList.Items))
        $distribution = $distributions |
            Where-Object { $_.Aliases -and $_.Aliases.Items -contains $Assets } |
            Select-Object -First 1
        if ($distribution) {
            Write-Host "UPSERT assets alias: $Assets -> $($distribution.DomainName)" -ForegroundColor Cyan
            Upsert-Route53AliasRecord -ZoneId $ZoneId -Name $Assets -DnsName $distribution.DomainName -TargetHostedZoneId $CloudFrontHostedZoneId
        }
        else {
            Write-Host "CloudFront distribution untuk $Assets belum tersedia; record assets dibuat setelah deploy menghasilkan target." -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "Gagal mengecek CloudFront distribution untuk alias awal." -ForegroundColor Yellow
        Write-Host (Format-CliResult -Result $distributionResult) -ForegroundColor DarkGray
    }
}

function Ensure-CertificateValidation {
    param(
        [Parameter(Mandatory = $true)][string]$CertificateArn,
        [Parameter(Mandatory = $true)][string]$Region,
        [string]$ZoneId
    )

    $records = @(Get-CertificateValidationRecords -CertificateArn $CertificateArn -Region $Region)
    if ($records.Count -eq 0) {
        return
    }

    if ([string]::IsNullOrWhiteSpace($ZoneId)) {
        foreach ($record in $records) {
            $ManualDnsRecords.Add($record)
        }
        return
    }

    foreach ($record in $records) {
        Write-Host "UPSERT DNS validation: $($record.Name) -> $($record.Value)" -ForegroundColor Cyan
        Upsert-Route53ValidationRecord -ZoneId $ZoneId -Record $record
    }

    if (-not $SkipCertificateWait) {
        try {
            Write-Host "Menunggu certificate ISSUED di $Region..." -ForegroundColor Cyan
            [void](Invoke-Aws -Arguments @(
                "acm", "wait", "certificate-validated",
                "--certificate-arn", $CertificateArn,
                "--region", $Region
            ))
            Write-Host "Certificate ISSUED: $CertificateArn" -ForegroundColor Green
        }
        catch {
            Write-Warning "Certificate belum ISSUED dalam window waiter AWS CLI. Cek DNS propagation lalu ulangi deploy."
        }
    }
}

function Set-GitHubVariable {
    param(
        [Parameter(Mandatory = $true)][string]$Repo,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Value
    )

    [void](Invoke-Gh -Arguments @("variable", "set", $Name, "--repo", $Repo, "--body", $Value))
}

function Set-GitHubSecretFromValue {
    param(
        [Parameter(Mandatory = $true)][string]$Repo,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Value
    )

    [void](Invoke-Gh -Arguments @("secret", "set", $Name, "--repo", $Repo) -StandardInput "$Value`n")
}

function Print-Summary {
    param(
        [string]$AccountId,
        [string]$Repo,
        [string]$Branch,
        [string]$StateBucket,
        [string]$RoleArn,
        [string]$Api,
        [string]$Frontend,
        [string]$Assets,
        [string]$ApiCertArn,
        [string]$AssetsCertArn,
        [bool]$NoCustomDomainEnabled
    )

    Write-Host ""
    Write-Host "Bootstrap summary" -ForegroundColor Green
    Write-Host "AWS_ACCOUNT_ID=$AccountId"
    Write-Host "NO_CUSTOM_DOMAIN=$($NoCustomDomainEnabled.ToString().ToLowerInvariant())"
    Write-Host "GITHUB_REPO=$Repo"
    Write-Host "GITHUB_BRANCH=$Branch"
    Write-Host "TF_STATE_BUCKET=$StateBucket"
    Write-Host "AWS_ROLE_ARN=$RoleArn"
    Write-Host "API_DOMAIN=$Api"
    Write-Host "FRONTEND_DOMAIN=$Frontend"
    Write-Host "ASSETS_DOMAIN=$Assets"
    Write-Host "ACM_CERTIFICATE_ARN=$ApiCertArn"
    Write-Host "ASSETS_ACM_CERTIFICATE_ARN=$AssetsCertArn"

    if ($ManualDnsRecords.Count -gt 0) {
        Write-Host ""
        Write-Host "DNS records manual yang harus dibuat:" -ForegroundColor Yellow
        $ManualDnsRecords |
            Select-Object DomainName, Region, Type, Name, Value |
            Format-Table -AutoSize
    }
    else {
        Write-Host ""
        Write-Host "Tidak ada DNS validation record manual yang tersisa dari bootstrap ini." -ForegroundColor Green
    }
}

try {
    Test-CommandAvailable -Name "aws"
    Test-CommandAvailable -Name "gh"

    if ([string]::IsNullOrWhiteSpace($AwsRegion)) {
        $AwsRegion = Read-Input -Name "AWS_REGION" -Default "ap-southeast-1" -Required
    }

    $noCustomDomainEnabled = $NoCustomDomain.IsPresent
    if (-not $noCustomDomainEnabled -and -not [string]::IsNullOrWhiteSpace($env:NO_CUSTOM_DOMAIN)) {
        $normalizedNoCustomDomain = $env:NO_CUSTOM_DOMAIN.Trim().ToLowerInvariant()
        $noCustomDomainEnabled = $normalizedNoCustomDomain -in @("true", "1", "yes")
    }
    if (-not $NoCustomDomain.IsPresent -and [string]::IsNullOrWhiteSpace($env:NO_CUSTOM_DOMAIN)) {
        $modeInput = Read-Input -Name "NO_CUSTOM_DOMAIN true|false" -Default "false"
        $noCustomDomainEnabled = $modeInput.Trim().ToLowerInvariant() -in @("true", "1", "yes")
    }

    if (-not $noCustomDomainEnabled) {
        if ([string]::IsNullOrWhiteSpace($BaseDomain)) {
            $BaseDomain = Read-Input -Name "BASE_DOMAIN, contoh example.com" -Required
        }
        if ([string]::IsNullOrWhiteSpace($ApiDomain)) {
            $ApiDomain = Read-Input -Name "API_DOMAIN" -Default "api.$BaseDomain" -Required
        }
        if ([string]::IsNullOrWhiteSpace($FrontendDomain)) {
            $FrontendDomain = Read-Input -Name "FRONTEND_DOMAIN" -Default "app.$BaseDomain" -Required
        }
        if ([string]::IsNullOrWhiteSpace($AssetsDomain)) {
            $AssetsDomain = Read-Input -Name "ASSETS_DOMAIN" -Default "assets.$BaseDomain" -Required
        }
    }
    if ([string]::IsNullOrWhiteSpace($GitHubRepo)) {
        $GitHubRepo = Read-Input -Name "GITHUB_REPO" -Default "Tim1357912/seera-chatbot" -Required
    }
    if ([string]::IsNullOrWhiteSpace($GitHubBranch)) {
        $GitHubBranch = Read-Input -Name "GITHUB_BRANCH" -Default "deploy" -Required
    }
    if (-not $noCustomDomainEnabled -and [string]::IsNullOrWhiteSpace($HostedZoneId)) {
        $HostedZoneId = Read-Input -Name "HOSTED_ZONE_ID optional, kosongkan jika domain bukan Route 53" -Default ""
    }

    Write-Host "Validasi AWS CLI login..." -ForegroundColor Cyan
    $accountId = Get-AwsAccountId
    Write-Host "AWS account: $accountId" -ForegroundColor Green

    Write-Host "Validasi GitHub CLI login..." -ForegroundColor Cyan
    [void](Invoke-Gh -Arguments @("auth", "status"))
    Write-Host "GitHub CLI authenticated." -ForegroundColor Green

    Test-AwsPermissionProbe -Region $AwsRegion -ZoneId $HostedZoneId -NoCustomDomainEnabled $noCustomDomainEnabled

    if ([string]::IsNullOrWhiteSpace($TfStateBucket)) {
        $TfStateBucket = Read-Input -Name "TF_STATE_BUCKET" -Default "seera-prod-tfstate-$accountId" -Required
    }

    Ensure-TerraformStateBucket -Bucket $TfStateBucket -Region $AwsRegion -SkipSetup $SkipStateBucketSetup.IsPresent
    $providerArn = Ensure-GitHubOidcProvider -AccountId $accountId
    $roleArn = Ensure-GitHubDeployRole `
        -AccountId $accountId `
        -ProviderArn $providerArn `
        -Repo $GitHubRepo `
        -Branch $GitHubBranch `
        -StateBucket $TfStateBucket

    $apiCertArn = ""
    $assetsCertArn = ""

    if (-not $noCustomDomainEnabled) {
        $apiCertArn = Get-OrRequestCertificate -Domain $ApiDomain -Region $AwsRegion
        $assetsCertArn = Get-OrRequestCertificate -Domain $AssetsDomain -Region $AssetsCertificateRegion

        Ensure-CertificateValidation -CertificateArn $apiCertArn -Region $AwsRegion -ZoneId $HostedZoneId
        Ensure-CertificateValidation -CertificateArn $assetsCertArn -Region $AssetsCertificateRegion -ZoneId $HostedZoneId
        Try-UpsertExistingApplicationRecords -ZoneId $HostedZoneId -Region $AwsRegion -Api $ApiDomain -Assets $AssetsDomain
    }

    Write-Host "Menulis GitHub Actions variables/secrets..." -ForegroundColor Cyan
    Set-GitHubVariable -Repo $GitHubRepo -Name "NO_CUSTOM_DOMAIN" -Value $(if ($noCustomDomainEnabled) { "true" } else { "false" })
    Set-GitHubVariable -Repo $GitHubRepo -Name "AWS_REGION" -Value $AwsRegion
    Set-GitHubVariable -Repo $GitHubRepo -Name "TF_STATE_BUCKET" -Value $TfStateBucket
    if (-not $noCustomDomainEnabled) {
        Set-GitHubVariable -Repo $GitHubRepo -Name "API_DOMAIN" -Value $ApiDomain
        Set-GitHubVariable -Repo $GitHubRepo -Name "FRONTEND_DOMAIN" -Value $FrontendDomain
        Set-GitHubVariable -Repo $GitHubRepo -Name "ACM_CERTIFICATE_ARN" -Value $apiCertArn
        Set-GitHubVariable -Repo $GitHubRepo -Name "ASSETS_DOMAIN" -Value $AssetsDomain
        Set-GitHubVariable -Repo $GitHubRepo -Name "ASSETS_ACM_CERTIFICATE_ARN" -Value $assetsCertArn
        if (-not [string]::IsNullOrWhiteSpace($HostedZoneId)) {
            Set-GitHubVariable -Repo $GitHubRepo -Name "HOSTED_ZONE_ID" -Value $HostedZoneId
        }
    }
    Set-GitHubSecretFromValue -Repo $GitHubRepo -Name "AWS_ROLE_ARN" -Value $roleArn

    Print-Summary `
        -AccountId $accountId `
        -Repo $GitHubRepo `
        -Branch $GitHubBranch `
        -StateBucket $TfStateBucket `
        -RoleArn $roleArn `
        -Api $ApiDomain `
        -Frontend $FrontendDomain `
        -Assets $AssetsDomain `
        -ApiCertArn $apiCertArn `
        -AssetsCertArn $assetsCertArn `
        -NoCustomDomainEnabled $noCustomDomainEnabled
}
catch {
    Write-Host ""
    Write-Host "Bootstrap gagal." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
