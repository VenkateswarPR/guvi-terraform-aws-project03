
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

module "networking" {
  source = "./modules/networking"

  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  availability_zones  = data.aws_availability_zones.available.names
}

module "compute" {
  source = "./modules/compute"

  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.networking.vpc_id
  subnet_id        = module.networking.public_subnet_ids[0]
  ami_id           = var.ami_id
  instance_type    = var.instance_type
  ssh_allowed_cidr = var.ssh_allowed_cidr
}

resource "aws_s3_bucket" "application" {
  bucket = "${var.project_name}-${data.aws_caller_identity.current.account_id}-${var.aws_region}"

  tags = {
    Name        = "${var.project_name}-application"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "application" {
  bucket = aws_s3_bucket.application.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "application" {
  bucket = aws_s3_bucket.application.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "application" {
  bucket = aws_s3_bucket.application.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
