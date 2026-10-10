
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = module.compute.instance_id
}

output "elastic_ip" {
  description = "Public Elastic IP address"
  value       = module.compute.elastic_ip
}

output "application_url" {
  description = "URL of the Nginx landing page"
  value       = "http://${module.compute.elastic_ip}"
}

output "s3_bucket_name" {
  description = "Name of the application S3 bucket"
  value       = aws_s3_bucket.application.bucket
}
