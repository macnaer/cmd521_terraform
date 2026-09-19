# EC2 Module

Provisions two EC2 instances (Ubuntu + Amazon Linux) in the configured AWS
region with a shared security group that allows SSH (22), HTTP (80) and ICMP
from the public internet.

## Resources

| Resource | Description |
|----------|-------------|
| `aws_instance.primary`   | Ubuntu EC2 instance |
| `aws_instance.secondary` | Amazon Linux EC2 instance |
| `aws_security_group.this`| Security group for both instances |
| `aws_security_group_rule.ingress` | Ingress rules (SSH/HTTP/ICMP) |
| `aws_security_group_rule.egress`  | Egress rule (allow all) |

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `aws_image_id`      | string | — | AMI ID of the primary (Ubuntu) instance |
| `aws_image_id_2`    | string | — | AMI ID of the secondary (Amazon Linux) instance |
| `aws_instance_type` | string | `t3.small` | EC2 instance type |
| `aws_key_name`      | string | — | Existing EC2 key pair name |
| `tags`              | map    | `{ManagedBy=Terraform}` | Common tags |

## Outputs

| Name | Description |
|------|-------------|
| `instance_public_ip_primary`   | Public IP of the primary instance |
| `instance_public_ip_secondary` | Public IP of the secondary instance |
| `security_group_id`            | ID of the shared security group |
