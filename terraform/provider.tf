provider "aws" {
  profile    = var.profile
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

/*resource "aws_key_pair" "deployer" {
   key_name   = "deployer-key"
   public_key = "ssh-rsa AAAAB3NzaC1y...and-so-on...1 email@example.com"
}
*/
/*
terraform {

  backend "s3" {
    
    bucket         = "nichiporenko-backend"
    key            = "terraform/final/terraform.tfstate"
    region         = "us-east-1"
    profile        = "final"
    dynamodb_table = "nichiporenko-dt"
    encrypt        = true

  }
}
*/