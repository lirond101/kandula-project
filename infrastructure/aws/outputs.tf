output "aws_alb_public_dns" {
  value = aws_lb.alb.dns_name
}

# output "web_bucket" {
#   value = aws_s3_bucket.nginx_access_log
# }