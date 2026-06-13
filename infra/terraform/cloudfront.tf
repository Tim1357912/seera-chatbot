data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer_except_host_header" {
  name = "Managed-AllViewerExceptHostHeader"
}

resource "aws_cloudfront_distribution" "backend" {
  count = var.no_custom_domain ? 1 : 0

  enabled     = true
  comment     = "${local.name_prefix} backend API"
  price_class = "PriceClass_100"

  origin {
    domain_name = aws_lb.api.dns_name
    origin_id   = "alb-backend"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id         = "alb-backend"
    viewer_protocol_policy   = "redirect-to-https"
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD", "OPTIONS"]
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer_except_host_header.id
    compress                 = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }

  tags = {
    Name = "${local.name_prefix}-backend-cdn"
  }
}

resource "aws_cloudfront_origin_access_control" "assets" {
  name                              = "${local.name_prefix}-assets-oac"
  description                       = "OAC for Seera static assets"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "assets" {
  enabled     = true
  comment     = "${local.name_prefix} static assets"
  aliases     = var.assets_domain != "" && var.assets_acm_certificate_arn != "" ? [var.assets_domain] : []
  price_class = "PriceClass_100"

  origin {
    domain_name              = aws_s3_bucket.assets.bucket_regional_domain_name
    origin_id                = "s3-assets"
    origin_access_control_id = aws_cloudfront_origin_access_control.assets.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-assets"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.assets_acm_certificate_arn == ""
    acm_certificate_arn            = var.assets_acm_certificate_arn != "" ? var.assets_acm_certificate_arn : null
    ssl_support_method             = var.assets_acm_certificate_arn != "" ? "sni-only" : null
    minimum_protocol_version       = var.assets_acm_certificate_arn != "" ? "TLSv1.2_2021" : "TLSv1"
  }

  tags = {
    Name = "${local.name_prefix}-assets-cdn"
  }
}
