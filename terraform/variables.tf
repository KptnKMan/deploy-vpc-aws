// Default variables file
// Variables here are used if no variable is set elsewhere
// Variables here are overriden by the deploy variables file

variable "cluster_config_location" {
  type    = string
  default = "config"
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "key_name" {
  type    = string
  default = "kareems-poc"
}

variable "deploy_name" {
  type    = string
  default = "Kareems POC Base VPC"
}

variable "deploy_name_short" {
  type    = string
  default = "kareempocvpc"
}

variable "dns_domain_public" {
  type = string
}

variable "dns_urls" {
  type = map(string)
  default = {
    url_bastion = "kareempoc-vpc-bastion"
  }
}

variable "deploy_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "private_cidr" {
  type    = list(string)
  default = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
}

variable "public_cidr" {
  type    = list(string)
  default = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]
}

variable "management_ips" {
  type = string
}

variable "management_ips_personal" {
  type = string
}

variable "instance_types" {
  default = {
    bastion      = "t3.micro"
    spot_max_bid = "0.073"
  }
}

variable "cluster_tags" {
  default = {
    Role          = "Dev"
    Service       = "Base Infrastructure"
    Business-Unit = "Operations"
    Owner         = "Ops"
    Purpose       = "Base VPC"
  }
}

