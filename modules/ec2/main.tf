###############################################################################
# MODULE: ec2                                                                #
# Address prefix in state/plan:  module.ec2                                  #
# Provisions:  2 EC2 instances + shared Security Group                        #
###############################################################################

resource "aws_instance" "primary" {
  ami           = var.aws_image_id
  instance_type = var.aws_instance_type
  key_name      = var.aws_key_name

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 20
    volume_type = "gp3"

    tags = {
      Name = "RootVolume"
    }
  }

  tags = {
    Name = "Ubuntu Instance"
  }

  vpc_security_group_ids = [aws_security_group.this.id]
}

resource "aws_instance" "secondary" {
  ami           = var.aws_image_id_2
  instance_type = var.aws_instance_type
  key_name      = var.aws_key_name

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 20
    volume_type = "gp3"

    tags = {
      Name = "RootVolume"
    }
  }

  tags = {
    Name = "Amazon EC2 Instance 2"
  }

  vpc_security_group_ids = [aws_security_group.this.id]
}

resource "aws_security_group" "this" {
  name        = "SG_Terraform"
  description = "Security group for Terraform demo"
}

resource "aws_security_group_rule" "ingress" {
  for_each = {
    "ssh"  = { from_port = 22, to_port = 22, protocol = "tcp", description = "SSH access" }
    "http" = { from_port = 80, to_port = 80, protocol = "tcp", description = "HTTP access" }
    "icmp" = { from_port = -1, to_port = -1, protocol = "icmp", description = "ICMP ping" }
  }

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = ["0.0.0.0/0"]
  description       = each.value.description
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}
