#!/bin/bash

printf "$(tput setaf 3)\n\
### README ###\n\
This script runs to set instance tags for spot instances\n\
because AWS API does not tag spot instances from a spot claim.\n\
### END README ###$(tput sgr 0)\n"

# Install additional requirements Ubuntu
sudo apt-get update && sudo apt-get install -y python-pip

# Install additional requirements Amazon/Redhat
sudo yum update -y && sudo yum install python-pip -y

# Install awscli
sudo pip install awscli

# Get spot instance request tags to tags.json file
AWS_ACCESS_KEY_ID=$1 AWS_SECRET_ACCESS_KEY=$2 aws --region $3 ec2 describe-spot-instance-requests --spot-instance-request-ids $4 --query 'SpotInstanceRequests[0].Tags' > tags.json

# Set instance tags from tags.json file
AWS_ACCESS_KEY_ID=$1 AWS_SECRET_ACCESS_KEY=$2 aws --region $3 ec2 create-tags --resources $5 --tags file://tags.json && rm -rf tags.json