resource "aws_amplify_app" "frontend" {
  count = var.enable_amplify ? 1 : 0

  name         = "${local.name_prefix}-frontend"
  repository   = trimspace(var.amplify_github_token) != "" ? "https://github.com/${var.github_repository}" : null
  access_token = trimspace(var.amplify_github_token) != "" ? var.amplify_github_token : null

  platform = "WEB"

  environment_variables = {
    VITE_API_BASE_URL   = local.api_base_url
    VITE_ASSET_BASE_URL = local.assets_base_url
  }

  build_spec = file("${path.module}/../../amplify.yml")

  tags = {
    Name = "${local.name_prefix}-frontend"
  }
}

resource "aws_amplify_branch" "frontend" {
  count = var.enable_amplify ? 1 : 0

  app_id            = aws_amplify_app.frontend[0].id
  branch_name       = var.github_branch
  enable_auto_build = trimspace(var.amplify_github_token) != ""
  framework         = "Vue"
  stage             = "PRODUCTION"

  environment_variables = {
    VITE_API_BASE_URL   = local.api_base_url
    VITE_ASSET_BASE_URL = local.assets_base_url
  }
}

resource "aws_amplify_domain_association" "frontend" {
  count = var.enable_amplify && var.enable_amplify_domain_association && var.amplify_domain_name != "" ? 1 : 0

  app_id      = aws_amplify_app.frontend[0].id
  domain_name = var.amplify_domain_name

  sub_domain {
    branch_name = aws_amplify_branch.frontend[0].branch_name
    prefix      = var.amplify_subdomain_prefix
  }
}
