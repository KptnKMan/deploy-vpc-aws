// Deploy variables file
// Variables here override the default variables file
// Variables here are overriden by command line and ENV variables at runtime

// Configure where to store config files, like state
# project_config_location = "config"

// Set AWS credentials and region
// Put these in here if you are not using ENV VARs
# aws_access_key          = "reYOURACCESSKEYHEREg"
# aws_secret_key          = "rePUTYOURSUPERSECRETHERETHISISANEXAMPLEr"
# aws_region              = "eu-west-1"

// private key file
# key_name                = "kareempoc"

// Long cluster/deploy name, used for descriptions
# deploy_name             = "Kareem POC Base VPC"

// Short version, used for naming and prefixes etc
# deploy_name_short       = "kareempocvpc"

// primary dns domain, aka route53 hosted zone / dns domain / etc
dns_domain_public       = "mydomain.com"

// URLs used by cluster, bastion DNS etc
# dns_urls = {
#   url_bastion           = "kareempoc-vpc-bastion"
# }

// Variables used for setting network defaults
# deploy_cidr             = "10.1.0.0/16"
# private_cidr            = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
# public_cidr             = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]

//Business IPs:            AddYourIpHERE
management_ips          = "1.1.1.1/32"

// Team Personal IPs:      AddYourPersonalIpHERE
management_ips_personal = "2.2.2.2/32"

// Instance configuration params
// bastion = instance sizes of bastion ec2 instance - may require terraform taint of ASG to update
// spot_max_bid = Not the spot price you pay all the time, but maximum bid
# instance_types = {
#   bastion               = "m3.medium"
#   spot_max_bid          = "0.073" // 0.073 = m3.medium on-demand
# }

// Common Tags for all resources in deployment
# cluster_tags = {
#   Role                  = "Dev"
#   Service               = "Base Infrastructure"
#   Business-Unit         = "INFRE"
#   Owner                 = "OpsEng"
#   Purpose               = "Base VPC"
# }
