# Seera AWS Deployment

Dokumen ini menjelaskan deployment production Seera Chatbot ke AWS tanpa access key statis dan tanpa fallback HTTP.

## Arsitektur

- Frontend Vue/Vite: AWS Amplify Hosting.
- Backend FastAPI: Docker image di ECR, dijalankan oleh ECS Fargate private subnet.
- Public API custom domain mode: Application Load Balancer HTTPS, listener 80 hanya redirect ke 443.
- Public API no custom domain mode: default domain CloudFront HTTPS di depan ALB HTTP origin. Browser tetap memakai HTTPS; ALB HTTP hanya origin dari CloudFront dan security group dibatasi ke AWS managed prefix list CloudFront origin-facing.
- Database: RDS PostgreSQL private subnet, `publicly_accessible = false`.
- Object storage: S3 bucket private + CloudFront Origin Access Control untuk aset katalog.
- Secrets: `DATABASE_URL` disimpan di AWS Secrets Manager dan disuntikkan ke ECS task sebagai secret.
- CI/CD: GitHub Actions dengan OIDC role, bukan AWS access key statis.

## Mapping Rubrik

- Level 1: ECS Fargate + public HTTPS API, Amplify, RDS PostgreSQL, dan aplikasi public via custom domain atau default AWS domain.
- Level 2: S3/CloudFront untuk aset katalog, bucket private, ECS stateless, file permanen tidak disimpan di container.
- Level 3: Backend berjalan dari Dockerfile production-ready, image dipush ke ECR, ECS memakai image ECR.
- Level 4: GitHub Actions OIDC menjalankan test, build, Terraform, image push, migration, seed, ECS update, Amplify deploy, dan health check.

## Required Inputs

Deployment mendukung dua mode:

- Custom domain mode: memakai domain pribadi untuk API/frontend/assets.
- No custom domain mode: set `NO_CUSTOM_DOMAIN=true` dan memakai default domain AWS.

### Custom Domain Mode

Isi nilai berikut sebelum menjalankan production deploy dengan domain pribadi:

| Input | Tempat | Contoh | Catatan |
| --- | --- | --- | --- |
| `AWS_REGION` | GitHub Variable | `ap-southeast-1` | Region resource regional. |
| `AWS_ROLE_ARN` | GitHub Secret | `arn:aws:iam::123456789012:role/github-seera-deploy` | Role OIDC GitHub. |
| `TF_STATE_BUCKET` | GitHub Variable | `seera-prod-tfstate` | S3 backend Terraform terenkripsi. |
| `API_DOMAIN` | GitHub Variable | `api.example.com` | Harus HTTPS via ALB. |
| `FRONTEND_DOMAIN` | GitHub Variable | `app.example.com` | Harus HTTPS via Amplify. |
| `ACM_CERTIFICATE_ARN` | GitHub Variable | `arn:aws:acm:ap-southeast-1:...` | Certificate regional untuk ALB. |
| `ASSETS_DOMAIN` | GitHub Variable | `assets.example.com` | Asset domain target. Jika belum memakai custom alias, workflow tetap mewajibkan input ini tetapi Terraform akan memakai generated CloudFront domain sebagai `ASSET_BASE_URL`. |

Opsional:

- `HOSTED_ZONE_ID`
- `ENABLE_NAT_GATEWAY=true|false`
- `ENABLE_VPC_ENDPOINTS=true|false`
- `ENABLE_AMPLIFY=true|false`
- `AMPLIFY_GITHUB_TOKEN`
- `ASSETS_ACM_CERTIFICATE_ARN` untuk custom CloudFront alias. Certificate CloudFront harus di `us-east-1`; tanpa ini, `ASSET_BASE_URL` memakai domain CloudFront generated.
- `AMPLIFY_DOMAIN_NAME` dan `AMPLIFY_SUBDOMAIN_PREFIX` bila domain Amplify ingin dikelola Terraform.

### No Custom Domain Mode

Set GitHub Variable:

```text
NO_CUSTOM_DOMAIN=true
```

Input wajib hanya:

| Input | Tempat | Contoh | Catatan |
| --- | --- | --- | --- |
| `NO_CUSTOM_DOMAIN` | GitHub Variable | `true` | Mengaktifkan default AWS domain mode. |
| `AWS_REGION` | GitHub Variable | `ap-southeast-1` | Region resource regional. |
| `AWS_ROLE_ARN` | GitHub Secret | `arn:aws:iam::123456789012:role/github-seera-deploy` | Role OIDC GitHub. |
| `TF_STATE_BUCKET` | GitHub Variable | `seera-prod-tfstate-123456789012` | S3 backend Terraform terenkripsi. |

Dalam mode ini:

- `BASE_DOMAIN`, `API_DOMAIN`, `FRONTEND_DOMAIN`, `ASSETS_DOMAIN`, dan `ACM_CERTIFICATE_ARN` tidak wajib.
- Backend public client tetap HTTPS melalui default domain CloudFront yang dibuat Terraform.
- ALB menjadi HTTP origin untuk CloudFront. Security group ALB membatasi HTTP origin ke AWS managed prefix list CloudFront origin-facing.
- Frontend memakai default domain Amplify branch, misalnya `https://deploy.<amplify-id>.amplifyapp.com`.
- Assets memakai default domain CloudFront dari S3.
- `VITE_API_BASE_URL` di Amplify memakai output `backend_cloudfront_domain_name`.
- `ASSET_BASE_URL` dan `VITE_ASSET_BASE_URL` memakai output `assets_cloudfront_domain_name`.
- `CORS_ORIGINS` backend memakai output `amplify_default_domain`.
- Setelah Amplify deploy, workflow menjalankan Terraform apply ulang dan ECS redeploy untuk memastikan CORS backend mengikuti Amplify default domain terbaru.
- Workflow mengekspor `TF_VAR_api_base_url_override`, `TF_VAR_assets_base_url_override`, dan `TF_VAR_frontend_origin_override` dari output Terraform sebelum task definition backend dibuat.

Konsekuensi dan batasan no custom domain mode:

- URL production tidak branded dan bisa berubah jika resource Amplify/CloudFront dibuat ulang.
- Tidak perlu ACM custom certificate untuk API/assets karena CloudFront default certificate dipakai.
- DNS pribadi tidak diperlukan, tetapi sharing URL ke user memakai domain AWS.
- Browser tetap melihat HTTPS untuk backend, frontend, dan assets.

## Bootstrap Otomatis

Script `scripts/bootstrap-aws-prereqs.ps1` membuat prasyarat production deploy yang bisa diotomasi via CLI. Script ini tidak membuat atau menyimpan AWS access key statis.

Prerequisite lokal:

- AWS CLI sudah login ke account AWS target, misalnya via IAM Identity Center:

```powershell
aws configure sso
aws sso login --profile <profile-name>
$env:AWS_PROFILE = "<profile-name>"
aws sts get-caller-identity
```

- GitHub CLI sudah login dan punya akses admin/secrets ke repo:

```powershell
gh auth login
gh auth status
```

Jalankan mode interaktif:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap-aws-prereqs.ps1
```

No custom domain mode:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap-aws-prereqs.ps1 `
  -NoCustomDomain `
  -AwsRegion ap-southeast-1 `
  -GitHubRepo Tim1357912/seera-chatbot `
  -GitHubBranch deploy
```

Custom domain mode non-interaktif:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap-aws-prereqs.ps1 `
  -AwsRegion ap-southeast-1 `
  -BaseDomain example.com `
  -GitHubRepo Tim1357912/seera-chatbot `
  -GitHubBranch deploy `
  -HostedZoneId Z1234567890
```

Input yang diminta script:

- `NO_CUSTOM_DOMAIN`, default `false`. Jika `true`, script tidak meminta domain pribadi atau ACM cert.
- `AWS_REGION`, default `ap-southeast-1`.
- `BASE_DOMAIN`, contoh `example.com`, hanya custom domain mode.
- `API_DOMAIN`, default `api.<BASE_DOMAIN>`, hanya custom domain mode.
- `FRONTEND_DOMAIN`, default `app.<BASE_DOMAIN>`, hanya custom domain mode.
- `ASSETS_DOMAIN`, default `assets.<BASE_DOMAIN>`, hanya custom domain mode.
- `GITHUB_REPO`, default `Tim1357912/seera-chatbot`.
- `GITHUB_BRANCH`, default `deploy`.
- `HOSTED_ZONE_ID`, optional dan hanya custom domain mode.
- `TF_STATE_BUCKET`, default `seera-prod-tfstate-<aws-account-id>`.

Yang dibuat otomatis:

- S3 bucket Terraform state dengan versioning, SSE AES256, dan block public access.
- IAM OIDC provider GitHub Actions untuk `https://token.actions.githubusercontent.com`.
- IAM role `github-seera-deploy` dengan trust policy dibatasi ke repo dan branch deploy.
- Inline deployment policy yang service-scoped untuk Terraform PRD v7. Script tidak memakai `AdministratorAccess`, tetapi permission tetap cukup luas untuk membuat VPC, ECS, ECR, RDS, ALB, ACM, S3, CloudFront, IAM role app, Secrets Manager, CloudWatch Logs, Application Auto Scaling, Route 53 opsional, dan Amplify.
- Custom domain mode: ACM certificate `API_DOMAIN` di `AWS_REGION` untuk ALB.
- Custom domain mode: ACM certificate `ASSETS_DOMAIN` di `us-east-1` untuk CloudFront custom alias.
- Custom domain mode: DNS validation records ACM bila `HOSTED_ZONE_ID` tersedia.
- Custom domain mode: Route 53 alias awal untuk `API_DOMAIN` dan `ASSETS_DOMAIN` bila ALB/CloudFront target sudah ada dari deploy sebelumnya. Jika target belum ada, record aplikasi dibuat/diarahkan setelah Terraform/deploy menghasilkan target.
- GitHub Actions Variables: `NO_CUSTOM_DOMAIN`, `AWS_REGION`, `TF_STATE_BUCKET`.
- Custom domain mode juga menulis: `API_DOMAIN`, `FRONTEND_DOMAIN`, `ACM_CERTIFICATE_ARN`, `ASSETS_DOMAIN`, `ASSETS_ACM_CERTIFICATE_ARN`, dan `HOSTED_ZONE_ID` bila diisi.
- GitHub Actions Secret: `AWS_ROLE_ARN`.

Yang masih manual bila domain tidak berada di Route 53:

- Buat CNAME DNS validation records yang dicetak script.
- Tunggu ACM certificate menjadi `ISSUED`.
- Pastikan domain API, frontend, dan assets memang milik kamu dan bisa diarahkan ke target AWS setelah Terraform/Amplify membuat targetnya.

Setelah bootstrap selesai, jalankan deploy. Untuk custom domain mode, pastikan certificate sudah `ISSUED` lebih dulu:

```powershell
gh workflow run deploy-aws.yml --repo Tim1357912/seera-chatbot --ref deploy
```

Alternatifnya, push commit ke branch `deploy`; workflow `.github/workflows/deploy-aws.yml` akan berjalan otomatis untuk path yang relevan.

## GitHub OIDC Role

Buat IAM role eksternal untuk GitHub Actions dan simpan ARN-nya sebagai `AWS_ROLE_ARN`. Trust policy minimal harus membatasi repo dan branch aktif:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<account-id>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:Tim1357912/seera-chatbot:ref:refs/heads/deploy"
        }
      }
    }
  ]
}
```

Role ini membutuhkan permission untuk Terraform mengelola VPC, ALB, ECS, ECR, RDS, S3, CloudFront, Secrets Manager, CloudWatch, Route 53 opsional, Amplify opsional, dan IAM role/policy yang didefinisikan di `infra/terraform`.

## Terraform Backend

Salin contoh backend lalu init dengan bucket state yang sudah ada:

```bash
cp infra/terraform/backend.tf.example infra/terraform/backend.tf
cd infra/terraform
terraform init \
  -backend-config="bucket=<tf-state-bucket>" \
  -backend-config="key=seera/prod/terraform.tfstate" \
  -backend-config="region=ap-southeast-1" \
  -backend-config="encrypt=true" \
  -backend-config="use_lockfile=true"
```

`use_lockfile` membutuhkan Terraform `>= 1.10`. Jika memakai versi lama, upgrade Terraform sebelum deploy.

## Object Storage

Terraform membuat bucket S3 private, enkripsi server-side, versioning, lifecycle noncurrent version 90 hari, public access block, bucket policy CloudFront OAC, dan CloudFront distribution. Backend menerima:

```text
S3_ASSET_BUCKET=<bucket>
ASSET_BASE_URL=https://<assets-domain-or-cloudfront-domain>
AWS_REGION=ap-southeast-1
```

Workflow deploy melakukan:

```bash
aws s3 sync public "s3://<asset-bucket>/" --exclude "*" --include "*.png" --include "*.svg"
```

Seed katalog menyimpan URL produk dari `ASSET_BASE_URL`, sehingga production tidak memakai path lokal seperti `/koko-putih.png`.

Amplify juga menerima `VITE_ASSET_BASE_URL` dari output Terraform agar katalog frontend memakai CloudFront/S3 untuk gambar produk dan koleksi.

## Workflow Deploy

Push ke branch `deploy` atau `workflow_dispatch` menjalankan `.github/workflows/deploy-aws.yml`:

1. Validasi input wajib.
2. Configure AWS credentials via OIDC.
3. Backend tests dan frontend build.
4. `terraform init`, `fmt`, `validate`.
5. Apply base infrastructure tanpa traffic backend image.
6. Capture output Terraform. Pada no custom domain mode, workflow mengisi:

```bash
VITE_API_BASE_URL=https://<backend_cloudfront_domain_name>
VITE_ASSET_BASE_URL=https://<assets_cloudfront_domain_name>
ASSET_BASE_URL=https://<assets_cloudfront_domain_name>
CORS_ORIGINS=https://<amplify_default_domain>
```

7. Build image backend dari `backend/`, push ke ECR tag `${github.sha}` dan `latest`.
8. Apply task definition dengan image baru dan CORS/assets URL dari output Terraform.
9. Sync aset statis ke S3.
10. Run one-off `alembic upgrade head`.
11. Run one-off `python -m app.seed.run_seed`.
12. Update ECS service ke task definition baru dan desired count `1`.
13. Wait service stable, target group healthy, curl `/health`.
14. Trigger Amplify release.
15. No custom domain mode: apply Terraform ulang dan force redeploy ECS untuk memastikan `CORS_ORIGINS` memakai Amplify default domain terbaru.
16. Verify backend dan frontend via HTTPS.

Jika migration atau seed gagal, workflow berhenti sebelum update ECS service.

## Safety

- `backend/Dockerfile` hanya menjalankan Uvicorn; seed/migration tidak berjalan saat API startup.
- `APP_ENV=production` tidak menjalankan `Base.metadata.create_all()`.
- Production menolak wildcard CORS dan mewajibkan HTTPS CORS origins.
- `run_seed.py` production hanya memverifikasi Alembic sudah di head.
- Seed katalog tidak delete/recreate `product_colors`; relasi warna di-upsert agar ID lama tetap dipertahankan.
- RDS berada di private subnet dan security group hanya mengizinkan port 5432 dari ECS SG.
- GitHub Actions memakai OIDC, bukan AWS access key statis.

## Rollback ECS

Cari task definition lama lalu update service:

```bash
aws ecs list-task-definitions --family-prefix seera-prod-backend --sort DESC
aws ecs update-service \
  --cluster seera-prod-cluster \
  --service seera-prod-backend \
  --task-definition <previous-task-definition-arn> \
  --desired-count 1 \
  --force-new-deployment
aws ecs wait services-stable --cluster seera-prod-cluster --services seera-prod-backend
```

## Destroy Infrastructure

Pastikan memang ingin menghapus production. Untuk RDS, ubah `db_deletion_protection=false` lebih dulu bila ingin destroy:

```bash
cd infra/terraform
terraform apply -var="db_deletion_protection=false"
terraform destroy
```

Jangan commit `backend.tf`, `.tfstate`, `.tfvars`, crash log, atau file `.env`.

## Troubleshooting

- Missing input: isi GitHub Variables/Secrets sesuai tabel required inputs.
- Mixed content custom domain mode: pastikan frontend memakai `VITE_API_BASE_URL=https://<API_DOMAIN>`.
- Mixed content no custom domain mode: pastikan workflow summary menampilkan `VITE_API_BASE_URL=https://<backend_cloudfront_domain_name>`, bukan ALB HTTP.
- CORS blocked custom domain mode: isi `CORS_ORIGINS=https://<FRONTEND_DOMAIN>`, jangan wildcard.
- CORS blocked no custom domain mode: jalankan ulang workflow agar step refresh CORS menulis `CORS_ORIGINS=https://<amplify_default_domain>` dan redeploy ECS.
- RDS timeout: cek ECS SG ke RDS SG port 5432 dan routing private subnet.
- ECS cannot pull image: aktifkan NAT Gateway atau VPC endpoints ECR + S3 + logs + secretsmanager.
- ECS cannot read secret: cek execution role punya `secretsmanager:GetSecretValue`.
- S3 access denied: cek task role S3 policy dan bucket policy CloudFront OAC.
- CloudFront asset not found: pastikan workflow `aws s3 sync public` sukses dan URL memakai `ASSET_BASE_URL`.
- Migration failed: baca `aws logs tail /ecs/seera-prod-backend --since 20m`.
- Seed failed: pastikan schema sudah `alembic upgrade head`, lalu ulang workflow.
- ALB unhealthy: cek `/health`, target group port 8000, dan ECS task logs.
- Amplify env missing: pastikan Amplify branch env memiliki `VITE_API_BASE_URL` dan `VITE_ASSET_BASE_URL` dari Terraform output.
