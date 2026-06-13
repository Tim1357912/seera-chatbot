output "ecr_repository_url" {
  description = "Backend ECR repository URL."
  value       = aws_ecr_repository.backend.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name."
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS backend service name."
  value       = "${local.name_prefix}-backend"
}

output "backend_task_family" {
  description = "ECS backend task definition family."
  value       = "${local.name_prefix}-backend"
}

output "backend_task_definition_arn" {
  description = "Latest backend task definition ARN created by Terraform."
  value       = local.has_backend_image ? aws_ecs_task_definition.backend[0].arn : ""
}

output "backend_target_group_arn" {
  description = "Backend ALB target group ARN."
  value       = aws_lb_target_group.backend.arn
}

output "alb_dns_name" {
  description = "Public ALB DNS name."
  value       = aws_lb.api.dns_name
}

output "api_base_url" {
  description = "Production API base URL."
  value       = local.api_base_url
}

output "backend_cloudfront_domain_name" {
  description = "Default CloudFront domain for backend API when no_custom_domain is true."
  value       = var.no_custom_domain ? aws_cloudfront_distribution.backend[0].domain_name : ""
}

output "private_subnet_ids" {
  description = "Private subnet IDs for ECS one-off tasks."
  value       = values(aws_subnet.private)[*].id
}

output "ecs_security_group_id" {
  description = "ECS task security group ID."
  value       = aws_security_group.ecs.id
}

output "backend_log_group_name" {
  description = "CloudWatch log group for backend ECS tasks."
  value       = aws_cloudwatch_log_group.backend.name
}

output "database_url_secret_arn" {
  description = "Secrets Manager ARN containing DATABASE_URL."
  value       = aws_secretsmanager_secret.database_url.arn
  sensitive   = true
}

output "s3_assets_bucket_name" {
  description = "S3 bucket for static assets."
  value       = aws_s3_bucket.assets.bucket
}

output "assets_base_url" {
  description = "HTTPS base URL for static assets."
  value       = local.assets_base_url
}

output "assets_cloudfront_domain_name" {
  description = "Default CloudFront domain for static assets."
  value       = aws_cloudfront_distribution.assets.domain_name
}

output "cloudfront_distribution_domain_name" {
  description = "CloudFront distribution domain for static assets."
  value       = aws_cloudfront_distribution.assets.domain_name
}

output "amplify_app_id" {
  description = "Amplify app ID."
  value       = var.enable_amplify ? aws_amplify_app.frontend[0].id : ""
}

output "amplify_default_domain" {
  description = "Amplify branch default domain used as public frontend URL in no custom domain mode."
  value       = local.amplify_domain
}
