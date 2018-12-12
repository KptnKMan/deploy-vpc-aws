// Configure where to store config files, like state
# project_config_location = "config"

// Set AWS credentials and region
// Put these in here if you are not using ENV VARs
# aws_access_key          = "reYOURACCESSKEYHEREg"
# aws_secret_key          = "rePUTYOURSUPERSECRETHERETHISISANEXAMPLEr"
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

//Business IPs:            WorkivaAmsterdam   WorkivaAmes        ISUGuest           AmesRadissom      MikesHouse
management_ips          = "193.240.177.194/32,205.237.120.225/32,129.186.251.116/32,63.236.134.110/32,94.2.114.207/32"

// Team Personal IPs:      KareemHome       HotspotAmes
management_ips_personal = "80.114.86.181/32,172.56.11.48/32"

instance_types = {
  // instance sizes of ec2 instances - may require terraform taint of ASG to update
  bastion               = "m3.medium" // "m3.medium"

  // Not the spot price you pay all the time, but maximum bid
  spot_max_bid          = "0.073" // 0.073 = m3.medium on-demand
}

// Common Tags for all resources in deployment
cluster_tags = {
  Role                  = "Dev"
  Service               = "Base Infrastructure"
  Business-Unit         = "INFRE"
  Owner                 = "OpsEng"
  Purpose               = "Base VPC"
}
