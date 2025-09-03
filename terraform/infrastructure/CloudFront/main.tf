resource "aws_lb" "api" {
  name               = "${var.name}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups = [var.security_group_alb_id]
  subnets                    = var.alb_subnets
  enable_deletion_protection = false
  idle_timeout               = 300
  preserve_host_header       = false
  }

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.api.arn
  port              = var.alb_port
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404 Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_cloudfront_vpc_origin" "this" {
  vpc_origin_endpoint_config {
    arn                    = aws_lb.api.arn
    http_port              = var.alb_port
    https_port             = 443
    name                   = "cluster-${var.name}"
    origin_protocol_policy = "http-only"

    origin_ssl_protocols {
      items    = ["TLSv1.2"]
      quantity = 1
    }
  }
}


resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "s3-oac"
  description                       = "OAC for S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled     = true
  default_root_object = "index.html"
  price_class = "PriceClass_100"
    depends_on = [data.aws_s3_bucket_policy.frontend_policy]

  origins {
      domain_name              = aws_s3_bucket.this.bucket_regional_domain_name
      origin_id                = "s3-origin-${var.name}"
      origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
    }

  origins {
    domain_name = aws_lb.this.dns_name
    origin_id   = "cluster-${var.name}"

    vpc_origin_config = {
      vpc_origin_id = aws_cloudfront_vpc_origin.this.id
    }
  }

  default_cache_behavior {
    target_origin_id       = "s3-origin-${var.name}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior  {
    path_pattern           = "/api/*"
    target_origin_id       = "cluster-${var.name}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = true

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
    cloudfront_default_certificate = true
  }
}