// Primary Deployment VPC
module "deploy_vpc" {
  #source               = "github.com/terraform-community-modules/tf_aws_vpc" # depreciated
  source               = "github.com/terraform-aws-modules/terraform-aws-vpc" # replaced depreciated module repo
  #source               = "terraform-aws-modules/vpc/aws" # same as new module repo

  name                 = "${var.cluster_name}-deploy-vpc"

  azs                  = "${var.aws_availability_zones}"

  cidr                 = "${var.deploy_cidr}"
  private_subnets      = "${var.private_cidr}"
  public_subnets       = "${var.public_cidr}"
  
  map_public_ip_on_launch = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway   = true
  single_nat_gateway   = true

  enable_vpn_gateway   = false

  enable_s3_endpoint   = false
  enable_dynamodb_endpoint = false

  tags {
    Terraform          = "${var.cluster_tags["Terraform"]}"
    Env                = "${var.cluster_tags["Env"]}"
    Role               = "${var.cluster_tags["Role"]}"
    Owner              = "${var.cluster_tags["Owner"]}"
    Team               = "${var.cluster_tags["Team"]}"
    Project-Budget     = "${var.cluster_tags["Project-Budget"]}"
    ScheduleInfo       = "${var.cluster_tags["ScheduleInfo"]}"
    MonitoringInfo     = "${var.cluster_tags["MonitoringInfo"]}"
  }
}

// THIS IS USED FOR TESTING!!!
// SETS ALL ACCESS TO EVERYTHING INTERNALLY
#resource "aws_security_group_rule" "allow_all" {
#  type          = "ingress"
#  from_port     = 0
#  to_port       = 0
#  protocol      = "-1"
#  security_group_id = "${aws_security_group.common_sg.id}"
#  cidr_blocks   = ["${var.deploy_cidr}"]
#}

// Common Security Group for all machines
resource "aws_security_group" "common_sg" {
  name          = "${var.cluster_name_short}-sg-common"
  description   = "Traffic support on all machines"
  vpc_id        = "${module.deploy_vpc.vpc_id}"

  // Allow all outbound tcp traffic
  egress {
    from_port   = "0"
    to_port     = "65535"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  // Allow all outbound udp traffic
  egress {
    from_port   = "0"
    to_port     = "65535"
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  // Allow all systems to ping each other
  egress {
    from_port = "8"
    to_port   = "0"
    protocol  = "icmp"
    self      = true
  }

  // Allow ping from management ips
  ingress {
    from_port   = "8"
    to_port     = "0"
    protocol    = "icmp"
    self        = true
    cidr_blocks = ["${split(",", var.management_ips)}","${split(",", var.management_ips_personal)}"]
  }

  // Allow SSH from bastion
  ingress {
    from_port       = "22"
    to_port         = "22"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion_sg.id}"]
  }

  // set tags
  tags {
    Name               = "${var.cluster_name_short}-sg-common"
    Terraform          = "${var.cluster_tags["Terraform"]}"
    Env                = "${var.cluster_tags["Env"]}"
    Role               = "${var.cluster_tags["Role"]}"
    Owner              = "${var.cluster_tags["Owner"]}"
    Team               = "${var.cluster_tags["Team"]}"
    Project-Budget     = "${var.cluster_tags["Project-Budget"]}"
    ScheduleInfo       = "${var.cluster_tags["ScheduleInfo"]}"
    MonitoringInfo     = "${var.cluster_tags["MonitoringInfo"]}"
  }
}

// Outputs
output "vpc_region" {
  value = "${var.aws_region}"
}

output "vpc_region_azs" {
  value = "${var.aws_availability_zones}"
}

output "vpc_region_azs2" {
  value = "${var.aws_availability_zones}"
}

output "vpc_id" {
  value = "${module.deploy_vpc.vpc_id}"
}

output "vpc_subnets_public" {
  value = "${module.deploy_vpc.public_subnets}"
}

output "vpc_subnets_private" {
  value = "${module.deploy_vpc.private_subnets}"
}

output "common_sg_id" {
  value = "${aws_security_group.common_sg.id}"
}
