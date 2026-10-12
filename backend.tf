
terraform {
  backend "s3" {
    bucket       = "guvi-project03-tfstate-468907522316"
    key          = "project03/dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
