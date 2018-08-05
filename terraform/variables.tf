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

variable "cluster_name" {
  type = "string"
}

variable "cluster_name_short" {
  type = "string"
}

variable "s3_backup_bucket" {
  type = "string"
}

variable "s3_state_bucket" {
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

variable "cluster_tags" {
  default = {
    Terraform           = "true"
    Env                 = "Deployment"
    Role                = "Deployment"
    Owner               = "Kareem Operations"
    Team                = "Kareem Operations"
    Project-Budget      = "some-project-tag"
    ScheduleInfo        = "StopNever"
    MonitoringInfo      = "1"
  }
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
