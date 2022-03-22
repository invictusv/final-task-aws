
variable "cidr_block" {
  description = "VPC ip range"
  type = string   
}


variable "region" {
    description = "Region to deploy server"
    type = string   
    default = "us-east-1"  
    
}


variable "namespace" {
  type        = string
  description = "tags Namespace"

}


/*
variable "common-tags" {
    description = "Common tags to apply to all resuorces"
    type        = map
    default     = {
        Namespace = "nichiporenko",
        Owner = "nichiporenko",
        Project = "AWS"

    } 
  
}
*/
variable "stage" {
    description = "Project environment"
    type = string  
    
}

variable "profile" {
    description = "Profile keep credencionals to cloud"
    type = string  
    
}

/*
variable "db_identifier" {
  description = "Identifier db"
  type        = string
}

variable "dbname" {
  description = "Name db"
  type        = string
}

variable "db_engine" {
  description = "Engine db"
  type        = string
  default     = "mysql"
}

variable "db_version" {
  description = "Version engine db"
  type        = string
}
*/
variable "instance_class" {
  description = "Instance type"
  type        = string
  default     = "db.t2.micro"
}

variable "storage" {
  description = "Storage"
  type        = string
  default     = "20"
}

/*
variable "db_user" {
  description = "Db user"
  type        = string
  default     = "db_admin"
}

variable "pass" {
  description = "Password"
  type        = string
  default     = "vmnwordpress"
}
*/
variable "port" {
  description = "Port for connection to db"
  type        = number
  default     = "3306"
}

variable "delete_protection" {
  description = "Protect db from deletion or not"
  type        = string
  default     = "true"
}

variable "sg" {
  description = "VPC security group"
  type        = string
  default     = "homework"
}


#Access key for AWS

variable "access_key" {
    type = string
    description = "access_key AWS"
}

variable "secret_key" {
    type = string
    description = "secret_key AWS"
}