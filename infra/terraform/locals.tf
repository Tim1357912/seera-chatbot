data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name_prefix       = "${var.project_name}-${var.environment}"
  account_id        = data.aws_caller_identity.current.account_id
  azs               = slice(data.aws_availability_zones.available.names, 0, 2)
  has_backend_image = trimspace(var.backend_image_uri) != ""
  assets_bucket     = var.assets_bucket_name != "" ? var.assets_bucket_name : "${local.name_prefix}-assets-${local.account_id}"
  amplify_domain    = var.enable_amplify ? "${var.github_branch}.${aws_amplify_app.frontend[0].default_domain}" : ""

  computed_api_base_url    = var.no_custom_domain ? "https://${aws_cloudfront_distribution.backend[0].domain_name}" : "https://${var.api_domain}"
  computed_frontend_origin = var.no_custom_domain ? "https://${local.amplify_domain}" : "https://${var.frontend_domain}"
  computed_assets_base_url = var.no_custom_domain || var.assets_domain == "" || var.assets_acm_certificate_arn == "" ? "https://${aws_cloudfront_distribution.assets.domain_name}" : "https://${var.assets_domain}"

  api_base_url    = trimspace(var.api_base_url_override) != "" ? trimspace(var.api_base_url_override) : local.computed_api_base_url
  frontend_origin = trimspace(var.frontend_origin_override) != "" ? trimspace(var.frontend_origin_override) : local.computed_frontend_origin
  assets_base_url = trimspace(var.assets_base_url_override) != "" ? trimspace(var.assets_base_url_override) : local.computed_assets_base_url

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
