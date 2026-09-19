output "instance_public_ip_primary" {
  description = "Public IP address of the primary Ubuntu EC2 instance"
  value       = module.ec2.instance_public_ip_primary
}

output "instance_public_ip_secondary" {
  description = "Public IP address of the secondary Amazon Linux EC2 instance"
  value       = module.ec2.instance_public_ip_secondary
}

output "security_group_id" {
  description = "ID of the shared EC2 security group"
  value       = module.ec2.security_group_id
}

output "s3_bucket_id" {
  description = "ID (name) of the S3 static website bucket"
  value       = module.s3_static_website.bucket_id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 static website bucket"
  value       = module.s3_static_website.bucket_arn
}

output "s3_bucket_domain_name" {
  description = "S3 REST endpoint of the bucket (non-website)"
  value       = module.s3_static_website.bucket_domain_name
}

output "s3_website_endpoint" {
  description = "S3 website endpoint (HTTP only)"
  value       = module.s3_static_website.website_endpoint
}

output "s3_website_url" {
  description = "Full HTTP URL of the S3 static website"
  value       = module.s3_static_website.website_url
}

output "s3_uploaded_object_count" {
  description = "Number of static assets uploaded to the bucket"
  value       = module.s3_static_website.object_count
}
