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
            "Action": [
                "ec2:*",
                "elasticloadbalancing:*",
                "autoscaling:*",
                "sqs:*",
                "sns:*",
                "s3:*"
            ],
            "Resource": ["*"]
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

resource "aws_iam_role_policy" "machine_role_policy_allow_all_ssm" {
  name = "${var.cluster_name_short}-machine-role-policy-all-ssm"
  role = "${aws_iam_role.machine_role.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAccessToSSM",
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeAssociation",
                "ssm:ListAssociations",
                "ssm:GetDocument",
                "ssm:ListInstanceAssociations",
                "ssm:UpdateAssociationStatus",
                "ssm:UpdateInstanceInformation",
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply",
                "ds:CreateComputer",
                "ds:DescribeDirectories",
                "ec2:DescribeInstanceStatus"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "machine_role_policy_allow_kube_ingress" {
  name = "${var.cluster_name_short}-machine-role-policy-kube-ingress"
  role = "${aws_iam_role.machine_role.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowKubeIngressController",
        "Effect": "Allow",
        "Action": [
          "acm:ListCertificates",
          "acm:DescribeCertificate",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeLoadBalancerTargetGroups",
          "autoscaling:AttachLoadBalancers",
          "autoscaling:DetachLoadBalancers",
          "autoscaling:DetachLoadBalancerTargetGroups",
          "autoscaling:AttachLoadBalancerTargetGroups",
          "cloudformation:*",
          "elasticloadbalancing:*",
          "elasticloadbalancingv2:*",
          "ec2:DescribeInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeRouteTables",
          "ec2:DescribeVpcs",
          "iam:GetServerCertificate",
          "iam:ListServerCertificates"
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

// Role for lifecycle, because a separate role is required
resource "aws_iam_role" "lifecycle_role" {
  name = "${var.cluster_name_short}-lifecycle-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "autoscaling.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

// IAM Role Policy for lifecycle_role
resource "aws_iam_role_policy" "lifecycle_role_policy" {
  name = "${var.cluster_name_short}-lifecycle-role-policy"
  role = "${aws_iam_role.lifecycle_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*",
                "elasticloadbalancing:*",
                "autoscaling:*",
                "sqs:*",
                "sns:*",
                "s3:*"
            ],
            "Resource": ["*"]
        }
    ]
}
EOF
}

// Outputs
output "ami_id_ubuntu" {
  value = "${data.aws_ami.ubuntu_ami.image_id}"
}

output "ami_id_amazon" {
  value = "${data.aws_ami.amazon_ami.image_id}"
}

output "iam_instance_profile" {
  value = "${aws_iam_instance_profile.instance_profile.arn}"
}

output "iam_role" {
  value = "${aws_iam_role.machine_role.arn}"
}

output "iam_role_lifecycle" {
  value = "${aws_iam_role.lifecycle_role.arn}"
}

output "key_pair_name" {
  value = "${aws_key_pair.key_pair.key_name}"
}

output "management_ips" {
  value = "${var.management_ips}"
}

output "management_ips_personal" {
  value = "${var.management_ips_personal}"
}
