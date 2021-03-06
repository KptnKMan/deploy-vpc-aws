// CONFIGURE ROUTE53 DNS ZONE
data "aws_route53_zone" "dns_domain_public" {
  name         = "${var.dns_domain_public}."
  #private_zone = true
}

// Primary www

// PROD URLs

// ACC URLs

// OPS/MGMT URLs

## apiserver.mydomain.com

## clustername-bastion.mydomain.com

resource "aws_route53_record" "ops_bastion" {
  zone_id = "${data.aws_route53_zone.dns_domain_public.zone_id}"
  name    = "${var.dns_urls["url_bastion"]}"
  type    = "CNAME"
  ttl     = "5"

  weighted_routing_policy {
    weight = 10
  }

  set_identifier = "${var.dns_urls["url_bastion"]}"
  records        = ["${aws_spot_instance_request.bastion_server.public_dns}"]
}

# resource "aws_route53_record" "ops_bastion" {
#   zone_id = "${data.aws_route53_zone.dns_domain_public.zone_id}"
#   name    = "${var.dns_urls["url_bastion"]}"
#   type    = "A"
#   ttl     = "60"
#   records = ["${aws_spot_instance_request.bastion_server.public_ip}"]
# }

## clustername.mydomain.com

## clustername-jenkins.mydomain.com

## clustername-kibana.mydomain.com

## clustername-grafana.mydomain.com

## clustername-sonar.mydomain.com

// Outputs
output "_connect_bastion_r53" {
  value = "connect to bastion using: ssh -A ec2-user@${aws_route53_record.ops_bastion.fqdn}"
}

output "route53_zone_id" {
  value = "${data.aws_route53_zone.dns_domain_public.zone_id}"
}