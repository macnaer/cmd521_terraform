output "bucket_id" {
  description = "ID (name) of the S3 bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "Bucket domain name (e.g. bucket-name.s3.amazonaws.com)"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "website_endpoint" {
  description = "S3 website endpoint (HTTP only, no CDN)"
  value       = aws_s3_bucket_website_configuration.this.website_endpoint
}

output "website_url" {
  description = "Full HTTP URL of the S3 static website"
  value       = "http://${aws_s3_bucket_website_configuration.this.website_endpoint}"
}

output "object_count" {
  description = "Number of objects uploaded to the bucket"
  value       = length(aws_s3_object.files)
}
