// Set AWS region details
# aws_region              = "eu-west-1"
# aws_availability_zones  = ["eu-west-1a","eu-west-1b","eu-west-1c"]

// private key file
key_name                = "kareempoc"

cluster_name            = "Kareem POC Deployment"

cluster_name_short      = "kareempoc"

s3_backup_bucket        = "kareempoc-backup"

s3_state_bucket         = "kareempoc-state"

// primary dns domain, aka route53 hosted zone / dns domain / etc
dns_domain_public       = "bifromedia.com"

dns_urls = {
  primary_domain        = "bifromedia.com"
  url_bastion           = "kareempoc-bastion"
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
  bastion               = "t2.micro" // "m3.medium"

  // Not the spot price you pay all the time, but maximum bid
  spot_max_bid          = "7.2"
}

cluster_tags = {
  Env                   = "Kareem POC Deployment"
  Role                  = "Kareem POC Deployment"
  Owner                 = "Kareem Operations"
  Team                  = "Kareem Operations"
  Project-Budget        = "kareem-project-code"
  ScheduleInfo          = "StopToday"
  MonitoringInfo        = "1"
}
