// Security Group for bastion
resource "aws_security_group" "bastion_sg" {
  name        = "${var.deploy_name_short}-sg-bastion"
  description = "base deploy ${var.deploy_name_short} Bastion host traffic"
  vpc_id      = module.deploy_vpc.vpc_id

  # Allow incoming SSH from management ips
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = split(",", join(",", [var.management_ips, var.management_ips_personal]))
  }

  tags = merge(
    local.aws_tags,
    {
      "Name" = "${var.deploy_name_short}-sg-bastion"
    },
  )
}

// Cloud config template for bastion
data "template_file" "cloud_config_amzlinux_bastion" {
  template = file("terraform/templates/cloud_config_amzlinux_bastion.yml")
}

// EC2 Instance for bastion (SPOT REQUEST)
resource "aws_spot_instance_request" "bastion_server" {
  ami                  = data.aws_ami.amazon_ami.id #"${lookup(var.ubuntu_amis, var.aws_region)}"
  instance_type        = var.instance_types["bastion"]
  key_name             = aws_key_pair.key_pair.key_name
  iam_instance_profile = aws_iam_instance_profile.instance_profile.id

  vpc_security_group_ids = [aws_security_group.common_sg.id, aws_security_group.bastion_sg.id]
  subnet_id              = random_shuffle.random_az.result[0]

  user_data                   = data.template_file.cloud_config_amzlinux_bastion.rendered
  associate_public_ip_address = true

  spot_type            = "persistent"
  spot_price           = var.instance_types["spot_max_bid"]
  wait_for_fulfillment = true

  // Tag will not be added. Below script will copy tags from spot request to the instance using AWS CLI.
  // https://github.com/terraform-providers/terraform-provider-aws/issues/32
  // More details: https://akomljen.com/terraform-and-aws-spot-instances/
  tags = merge(
    local.aws_tags,
    {
      "Name" = "${var.deploy_name_short}-spot-ec2-bastion"
    },
  )

  provisioner "file" {
    source      = "terraform/templates/set_spot_ec2_tags.sh"
    destination = "/home/ec2-user/set_spot_ec2_tags.sh"
    connection {
      host     = coalesce(self.public_ip, self.private_ip)
      # password = self.password != "" ? self.password : null
      type     = "ssh"
      user     = "ec2-user"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "bash /home/ec2-user/set_spot_ec2_tags.sh ${var.aws_access_key} ${var.aws_secret_key} ${var.aws_region} ${aws_spot_instance_request.bastion_server.id} ${aws_spot_instance_request.bastion_server.spot_instance_id}",
    ]
    connection {
      host     = coalesce(self.public_ip, self.private_ip)
      # password = self.password != "" ? self.password : null
      type     = "ssh"
      user     = "ec2-user"
    }
  }
}

// Outputs
output "_connect_bastion_ip" {
  value = "connect to bastion using: ssh -A ec2-user@${aws_spot_instance_request.bastion_server.public_ip}"
}

output "_connect_bastion_dns" {
  value = "connect to bastion using: ssh -A ec2-user@${aws_spot_instance_request.bastion_server.public_dns}"
}

output "sg_id_bastion" {
  value = aws_security_group.bastion_sg.id
}

