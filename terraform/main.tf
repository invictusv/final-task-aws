


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

/*module "db" {
  source = "terraform-aws-modules/rds/aws"
  version = "4.1.2"
  identifier = var.db_identifier

  engine               = var.db_engine
  engine_version       = var.db_version
  family               = "${var.db_engine}5.7" # DB parameter group
  major_engine_version = "5.7"                 # DB option group
  instance_class       = var.instance_class
  allocated_storage     = var.storage
  storage_encrypted     = false
  max_allocated_storage = 100
  db_name  = var.dbname
  username = var.db_user
  password = var.pass
  port     = var.port

  multi_az               = false
  create_db_subnet_group = true
  subnet_ids             = module.vpc.database_subnets
  vpc_security_group_ids = [module.db_security_group.security_group_id]

  maintenance_window = "Mon:00:00-Mon:02:00"
  backup_window      = "02:00-04:00"

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  tags = {
    Namespace = var.namespace,
    Stage     = var.stage,
    Name      = "${var.namespace}-db"
  }

  db_instance_tags = {
    "Sensitive" = "high"
  }
  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
  db_subnet_group_tags = {
    "Sensitive" = "high"
  }
}
*/
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.4.0"
  name = "${var.namespace}-ec2"
  ami           = "ami-04505e74c0741db8d"
  instance_type = "t2.micro"
  key_name               = "${var.namespace}"
  monitoring             = false
  vpc_security_group_ids = [module.ec2_security_group.security_group_id]
  subnet_id              = element(module.vpc.public_subnets, 0)

  associate_public_ip_address = true
  user_data = file("gitlab-runner.sh")

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