module "ec2" {
  source = "./modules/ec2"

  aws_image_id      = var.aws_image_id
  aws_image_id_2    = var.aws_image_id_2
  aws_instance_type = var.aws_instance_type
  aws_key_name      = var.aws_key_name
}

module "s3_static_website" {
  source = "./modules/s3-static-website"

  bucket_name            = var.s3_bucket_name
  force_destroy          = var.s3_force_destroy
  versioning_enabled     = var.s3_versioning_enabled
  website_index_document = var.s3_website_index_document
  website_error_document = var.s3_website_error_document
}

moved {
  from = aws_instance.EC2_instance
  to   = module.ec2.aws_instance.primary
}

moved {
  from = aws_instance.EC2_instance2
  to   = module.ec2.aws_instance.secondary
}

moved {
  from = aws_security_group.SG_Terrafrom
  to   = module.ec2.aws_security_group.this
}

moved {
  from = aws_security_group_rule.ingress_rule["ssh"]
  to   = module.ec2.aws_security_group_rule.ingress["ssh"]
}

moved {
  from = aws_security_group_rule.ingress_rule["http"]
  to   = module.ec2.aws_security_group_rule.ingress["http"]
}

moved {
  from = aws_security_group_rule.ingress_rule["icmp"]
  to   = module.ec2.aws_security_group_rule.ingress["icmp"]
}

moved {
  from = aws_security_group_rule.egress_rule
  to   = module.ec2.aws_security_group_rule.egress
}
