
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "elastic_ip" {
  description = "Elastic IP address of the web server"
  value       = aws_eip.web.public_ip
}

output "security_group_id" {
  description = "ID of the web server security group"
  value       = aws_security_group.web.id
}

output "iam_role_name" {
  description = "Name of the EC2 IAM role"
  value       = aws_iam_role.ec2_role.name
}

output "instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}
