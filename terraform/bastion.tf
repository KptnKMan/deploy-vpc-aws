// Security Group for bastion
resource "aws_security_group" "bastion_sg" {
  name        = "${var.cluster_name_short}-bastion"
  description = "Bastion host traffic"
  vpc_id      = "${module.deploy_vpc.vpc_id}"

  # Allow incoming SSH from management ips
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["${split(",", var.management_ips)}","${split(",", var.management_ips_personal)}"]
  }

  tags {
    Name               = "${var.cluster_name_short}-sg-bastion"
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

// Cloud config template for bastion
data "template_file" "bastion_cloud_config" {
  template = "${file("terraform/templates/bastion_cloud_config.yml")}"
}

// EIP for bastion
resource "aws_eip" "bastion_eip" {
  vpc = true
}

// Pick a random subnet for bastion
resource "random_shuffle" "bastion_az" {
  input = ["${join(",", module.deploy_vpc.public_subnets)}"] #["us-west-1a", "us-west-1c", "us-west-1d", "us-west-1e"]
  result_count = 1
}

// EC2 Instance for bastion
resource "aws_instance" "bastion_server" {
  ami                         = "${data.aws_ami.amazon_ami.id}" #"${lookup(var.ubuntu_amis, var.aws_region)}"
  instance_type               = "${var.instance_types["bastion"]}"
  key_name                    = "${aws_key_pair.key_pair.key_name}"
  iam_instance_profile        = "${aws_iam_instance_profile.instance_profile.id}"

  vpc_security_group_ids      = ["${aws_security_group.common_sg.id}", "${aws_security_group.bastion_sg.id}"]
  subnet_id                   = "${element(module.deploy_vpc.public_subnets, 0)}"
  #subnet_id                   = "${random_shuffle.bastion_az.result[0]}"
  
  user_data                   = "${data.template_file.bastion_cloud_config.rendered}"
  associate_public_ip_address = true

  tags {
    Name               = "${var.cluster_name_short}-ec2-bastion"
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

// Associate EIP to bastion instance
resource "aws_eip_association" "bastion_eip_assoc" {
  instance_id   = "${aws_instance.bastion_server.id}"
  allocation_id = "${aws_eip.bastion_eip.id}"
}

// Outputs
output "_connect_bastion_ip" {
  value = "connect to bastion using: ssh -A ec2-user@${aws_eip.bastion_eip.public_ip}"
}

output "_connect_bastion_dns" {
  value = "connect to bastion using: ssh -A ec2-user@${aws_instance.bastion_server.public_dns}"
}

output "bastion_sg_id" {
  value = "${aws_security_group.bastion_sg.id}"
}
