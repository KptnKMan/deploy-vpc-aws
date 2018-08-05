// Declare AWS provider for basically everything to follow
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"

  region = "${var.aws_region}"
}

// Keypair that will be associated with all instances
resource "aws_key_pair" "key_pair" {
  key_name   = "${var.key_name}"
  public_key = "${file("${var.cluster_config_location}/${var.key_name}.pub")}"
}

// Role assigned to all machines
resource "aws_iam_role" "machine_role" {
  name = "${var.cluster_name_short}-machine-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

// This policy allows Kubernetes to configure loadbalancing, attach volumes, etc.
// It also supports using the AWS cli to retrieve information about loadbalancers.
resource "aws_iam_role_policy" "machine_role_policy" {
  name = "${var.cluster_name_short}-machine-role-policy"
  role = "${aws_iam_role.machine_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ec2:*"],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": ["elasticloadbalancing:*", "autoscaling:*"],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "sqs:*",
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

// This policy allows Kubernetes to access CloudWatch for logs/metrics.
resource "aws_iam_role_policy" "machine_role_policy_cloudwatch" {
  name = "${var.cluster_name_short}-machine-role-policy-cloudwatch"
  role = "${aws_iam_role.machine_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:*",
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:logs:${var.aws_region}:*:*",
        "arn:aws:s3:::*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

// Instance profile for machines
resource "aws_iam_instance_profile" "instance_profile" {
  name  = "${var.cluster_name_short}-machine-instance-profile"
  path  = "/"
  role = "${aws_iam_role.machine_role.name}"
}

// Ubuntu AMI lookup
data "aws_ami" "ubuntu_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/*/ubuntu-xenial-16.04-amd64-server-*"] # <- search string to find ami
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"] # paravirtual or hvm
  }

  owners = ["099720109477"] # Canonical
}

// AmazonLinux2 AMI lookup
data "aws_ami" "amazon_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami*2018*x86_64*gp2"] # <- search string to find ami
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"] # paravirtual or hvm
  }

  owners = ["amazon"] # AWS Owned AMI
}

// Outputs
output "ami_id_ubuntu" {
  value = "${data.aws_ami.ubuntu_ami.image_id}"
}

output "ami_id_amazon" {
  value = "${data.aws_ami.amazon_ami.image_id}"
}

output "instance_profile_id" {
  value = "${aws_iam_instance_profile.instance_profile.id}"
}

output "key_pair_name" {
  value = "${aws_key_pair.key_pair.key_name}"
}
