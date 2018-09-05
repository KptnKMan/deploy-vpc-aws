variable "aws_access_key" {
  type = "string"
}

variable "aws_secret_key" {
  type = "string"
}

variable "aws_region" {
  type = "string"
  # default = "eu-west-1"
}

variable "aws_availability_zones" {
  type = "list"
  # default = ["eu-west-1a","eu-west-1b","eu-west-1c"]
}

variable "key_name" {
  type = "string"
}

variable "deploy_name" {
  type = "string"
}

variable "deploy_name_short" {
  type = "string"
}

variable "dns_domain_public" {
  type = "string"
}

variable "dns_urls" {
  type = "map"

  default = {
  }
}

variable "deploy_cidr" {
  type = "string"
}

variable "private_cidr" {
  type = "list"
}

variable "public_cidr" {
  type = "list"
}

variable "instance_types" {
  default = {
    bastion             = "t2.micro" #"m3.medium"

    spot_max_bid        = "7.2"
  }
}

variable "management_ips" {
  type = "string"
}

variable "management_ips_personal" {
  type = "string"
}

variable cluster_config_location {
  type = "string"
}

variable "cluster_tags" {
  default = {
    Role                = "Dev"
    Service             = "Base Infrastructure"
    Business-Unit       = "INFRE"
    Owner               = "OpsEng"
    Purpose             = "Base VPC"
  }
}
