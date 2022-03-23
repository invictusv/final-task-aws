


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${var.namespace}-vpc"
  cidr = "10.0.0.0/16" #var.cidr_blocks

  azs              = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets   = ["10.0.1.0/24", "10.0.4.0/24", "10.0.7.0/24"]
  private_subnets  = ["10.0.2.0/24", "10.0.5.0/24", "10.0.8.0/24"]
  database_subnets = ["10.0.3.0/24", "10.0.6.0/24", "10.0.9.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Namespace = var.namespace,
    Stage     = var.stage,
    Name      = "${var.namespace}-vpc"
  }
}

module "db_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.namespace}-db-sg"
  description = "MySQL security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]
  
  tags = {
    Namespace = var.namespace,
    Stage     = var.stage,
    Name      = "${var.namespace}-db-sg"
  }  
}

module "ec2_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.namespace}-ec2-sg"
  description = "EC2 security group"
  vpc_id      = module.vpc.vpc_id
  
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["all-all"]
  egress_rules        = ["all-all"]

  tags = {
    Namespace = var.namespace,
    Stage     = var.stage,
    Name      = "${var.namespace}-ec2-sg"
  }

}


module "ec2_instance" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "3.4.0"

  name = "${var.namespace}-ec2"
  ami                    = "ami-0b0ea68c435eb488d" #"ami-04505e74c0741db8d"
  instance_type          = "t2.micro"
  key_name               = "${var.namespace}"
  monitoring             = false
  vpc_security_group_ids = [module.ec2_security_group.security_group_id]
  subnet_id              = element(module.vpc.public_subnets, 0)

  associate_public_ip_address = true
  user_data              = file("gitlab-runner.sh")


  tags = {
    Namespace = var.namespace,
    Stage     = var.stage,
    Name      = "${var.namespace}-ec2"
  }
}


module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "nichiporenko-backend"
  acl    = "private"

  versioning = {
    enabled = true
  }

  tags = {
    Namespace = "${var.namespace}",
    Stage     = "${var.namespace}",
    Name      = "${var.namespace}-s3-bucket"
  }

}