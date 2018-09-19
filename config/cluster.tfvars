// Set AWS region details
aws_region              = "eu-west-1"

// private key file
key_name                = "kareempoc"

deploy_name             = "Kareem POC Base VPC"

deploy_name_short       = "kareempocvpc"

// primary dns domain, aka route53 hosted zone / dns domain / etc
dns_domain_public       = "bifromedia.com"

dns_urls = {
  url_bastion           = "kareempoc-vpc-bastion"
}

deploy_cidr             = "10.1.0.0/16"

private_cidr            = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]

public_cidr             = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]

//Business IPs:            AddYourIpHERE
management_ips          = "1.1.1.1/32"

// Team Personal IPs:      AddYourPersonalIpHERE
management_ips_personal = "2.2.2.2/32"

instance_types = {
  // instance sizes of ec2 instances - may require terraform taint of ASG to update
  bastion               = "t3.micro" // "m3.medium"

  // Not the spot price you pay all the time, but maximum bid
  spot_max_bid          = "7.2"
}

// Common Tags for all resources in deployment
cluster_tags = {
  Role                  = "Dev"
  Service               = "Base Infrastructure"
  Business-Unit         = "INFRE"
  Owner                 = "OpsEng"
  Purpose               = "Base VPC"
}
