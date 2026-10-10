
resource "aws_security_group" "web" {
  name_prefix = "web-dev-"
  description = "Allow HTTP and restricted SSH access"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH access from approved IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "web-dev"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role" "ec2_role" {
  name_prefix = "web-dev-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name_prefix = "web-dev-"
  role        = aws_iam_role.ec2_role.name
}

resource "aws_instance" "web" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.web.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -eux
    dnf install -y nginx
    systemctl enable nginx
    systemctl start nginx

    cat > /usr/share/nginx/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>GUVI Project-03</title>
    </head>
    <body>
      <h1>GUVI Project-03</h1>
      <h2>AWS Infrastructure Automation</h2>
      <p>Terraform + GitHub Actions</p>
      <p>Deployment successful!</p>
    </body>
    </html>
    HTML
  EOF

  user_data_replace_on_change = true

  tags = {
    Name        = "web-dev"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_eip" "web" {
  domain   = "vpc"
  instance = aws_instance.web.id

  tags = {
    Name        = "web-dev-eip"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
