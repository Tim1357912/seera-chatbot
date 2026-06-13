variable "project_name" {
  type        = string
  description = "Project name used for AWS resource names."
  default     = "seera"
}

variable "environment" {
  type        = string
  description = "Deployment environment name."
  default     = "prod"
}

variable "aws_region" {
  type        = string
  description = "AWS region for regional resources."
  default     = "ap-southeast-1"
}

variable "no_custom_domain" {
  type        = bool
  description = "Use AWS default domains only: CloudFront for backend/assets and Amplify default domain for frontend."
  default     = false
}

variable "github_repository" {
  type        = string
  description = "GitHub repository in owner/name form for Amplify."
  default     = "Tim1357912/seera-chatbot"
}

variable "github_branch" {
  type        = string
  description = "Branch that triggers CI/CD and Amplify."
  default     = "deploy"
}

variable "api_domain" {
  type        = string
  description = "HTTPS API domain routed to the ALB."
  default     = ""
}

variable "frontend_domain" {
  type        = string
  description = "HTTPS frontend domain served by Amplify."
  default     = ""
}

variable "assets_domain" {
  type        = string
  description = "Assets domain for ASSET_BASE_URL. Leave empty to use the generated CloudFront domain."
  default     = ""
}

variable "acm_certificate_arn" {
  type        = string
  description = "Regional ACM certificate ARN for the API ALB HTTPS listener."
  default     = ""
}

variable "assets_acm_certificate_arn" {
  type        = string
  description = "Optional us-east-1 ACM certificate ARN for a custom CloudFront assets alias."
  default     = ""
}

variable "hosted_zone_id" {
  type        = string
  description = "Optional Route 53 hosted zone ID for the API alias record."
  default     = ""
}

variable "api_base_url_override" {
  type        = string
  description = "Optional HTTPS API base URL populated by deploy workflow after Terraform outputs are known."
  default     = ""

  validation {
    condition     = var.api_base_url_override == "" || startswith(var.api_base_url_override, "https://")
    error_message = "api_base_url_override must be empty or an HTTPS URL."
  }
}

variable "frontend_origin_override" {
  type        = string
  description = "Optional HTTPS frontend origin for backend CORS, populated by deploy workflow after Amplify default domain is known."
  default     = ""

  validation {
    condition     = var.frontend_origin_override == "" || startswith(var.frontend_origin_override, "https://")
    error_message = "frontend_origin_override must be empty or an HTTPS origin."
  }
}

variable "assets_base_url_override" {
  type        = string
  description = "Optional HTTPS asset base URL populated by deploy workflow after assets CloudFront domain is known."
  default     = ""

  validation {
    condition     = var.assets_base_url_override == "" || startswith(var.assets_base_url_override, "https://")
    error_message = "assets_base_url_override must be empty or an HTTPS URL."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block."
  default     = "10.40.0.0/16"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Create a NAT Gateway for private ECS/RDS subnet egress."
  default     = true
}

variable "enable_vpc_endpoints" {
  type        = bool
  description = "Create VPC endpoints used by private ECS tasks."
  default     = false
}

variable "backend_image_uri" {
  type        = string
  description = "ECR image URI for backend. Empty string skips backend task definition/service creation."
  default     = ""
}

variable "backend_cpu" {
  type        = number
  description = "Fargate task CPU units."
  default     = 512
}

variable "backend_memory" {
  type        = number
  description = "Fargate task memory MiB."
  default     = 1024
}

variable "backend_desired_count_after_deploy" {
  type        = number
  description = "Desired count set by the deploy workflow after migration and seed succeed."
  default     = 1
}

variable "backend_max_capacity" {
  type        = number
  description = "Maximum ECS service capacity for autoscaling."
  default     = 3
}

variable "db_name" {
  type        = string
  description = "RDS database name."
  default     = "seera_chatbot"
}

variable "db_username" {
  type        = string
  description = "RDS master username."
  default     = "seera_admin"
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class."
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  type        = number
  description = "Allocated RDS storage in GiB."
  default     = 20
}

variable "db_deletion_protection" {
  type        = bool
  description = "Protect the RDS database from accidental deletion."
  default     = true
}

variable "assets_bucket_name" {
  type        = string
  description = "Optional explicit S3 bucket name for static assets."
  default     = ""
}

variable "enable_amplify" {
  type        = bool
  description = "Create Amplify app and branch."
  default     = true
}

variable "enable_amplify_domain_association" {
  type        = bool
  description = "Create an Amplify custom domain association when amplify_domain_name is provided."
  default     = false
}

variable "amplify_github_token" {
  type        = string
  description = "Optional GitHub token for Amplify when the GitHub App connection is not already configured."
  default     = ""
  sensitive   = true
}

variable "amplify_domain_name" {
  type        = string
  description = "Root domain for optional Amplify domain association, for example example.com."
  default     = ""
}

variable "amplify_subdomain_prefix" {
  type        = string
  description = "Subdomain prefix for optional Amplify domain association, for example app."
  default     = ""
}
