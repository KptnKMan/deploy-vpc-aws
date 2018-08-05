# Setup Doc
This doc is intended to help configure a working VPC environment

## Basic premise
* Pay attention to versions used. Use latest at your own risk.
* Unless specified, all commands are in bash (Linux/MacOS) or Powershell v4+ (Windows), make sure your package mgmt tool is updated (Eg: `apt-get update`)
* MacOS is assumed to be MacOSX (MacOS 10.12.6 tested)
* Linux is assumed to be Ubuntu 16.04
* Windows is assumed to be Microsoft Windows 10

# Setup Tools

## Setup Terraform
Linux:
```
curl -L https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip -o /tmp/terraform.zip && unzip -o /tmp/terraform.zip -d /tmp/
sudo mv /tmp/terraform /usr/bin/ && rm -Rf /tmp/terraform.zip
```
MacOS:
```
curl -L https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_darwin_amd64.zip -o /tmp/terraform.zip && unzip -o /tmp/terraform.zip -d /tmp/
sudo mv /tmp/terraform /usr/local/bin/ && rm -Rf /tmp/terraform.zip
```
Windows:
```
Invoke-WebRequest -Uri https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_windows_amd64.zip -Outfile $Env:USERPROFILE\Downloads\terraform_0.11.7_windows_amd64.zip
Expand-Archive $HOME\Downloads\terraform_0.11.7_windows_amd64.zip -DestinationPath $env:SystemRoot
```

# Setup Environment Variables

## Prepare Terraform variables
* Copy file `~/Projects/deploy-vpc-aws/aws_credentials.env.sample` to a new file `~/Projects/deploy-vpc-aws/aws_credentials.env.[YOUR CREDENTIALS]`
* Update the file with your credentials

Linux/MacOS:
```
source aws_credentials.env.[YOUR CREDENTIALS]
export AWS_AVAILABILITY_ZONES=$(aws ec2 describe-availability-zones --output text | awk '{print "\""$4"\""};' | tr '\n' ',' | sed 's/,*$//g')
```
Alternatively, to configure variables manually:
```
export AWS_ACCESS_KEY=AKIYOURACCESSKEYHERE
export AWS_SECRET_KEY=kTHISISWHEREYOUPUTYOURAWSSECRETKEYHEREt1
export AWS_DEFAULT_REGION=eu-central-1
export AWS_AVAILABILITY_ZONES=$(aws ec2 describe-availability-zones --output text | awk '{print "\""$4"\""};' | tr '\n' ',' | sed 's/,*$//g')

```
Windows:
```
Get-Content $HOME\Projects\deploy-vpc-aws\aws_credentials.env.[YOUR CREDENTIALS] | ForEach-Object { "$_"; $var = $_.Split('='); New-Variable -Name $var[0] -Value $var[1] -Scope Global }
function get-zones-short { $aws_zones_raw = @(); (aws ec2 describe-availability-zones) -split "\s" | ForEach-Object {$aws_zones_raw += Select-String -InputObject $_ -Pattern '([a-z]+-[a-z]+-[0-9][a-z])'}; $aws_zones1 = $aws_zones_raw  -replace '"','' -replace ',',''; $aws_zones2 = $aws_zones1 -join '\",\"'; $Global:AWS_ZONES = $aws_zones1 -join ','; $Global:AWS_AVAILABILITY_ZONES = '\"'+$aws_zones2+'\"' } get-zones-short; $Global:AWS_AVAILABILITY_ZONES
```

# Generate SSL key pair
* Generate an unencrypted private keypair
* This is the keypair for your infra, and should be kept SAFE
```
ssh-keygen -t rsa -b 2048 -f ~/Projects/deploy-vpc-aws/config/kareempoc
```

Verfify SSL cert:
```
openssl rsa -text -in ~/Projects/deploy-vpc-aws/config/kareempoc
```

# Creating and updating infrastructure

## Notes
* make sure all commands are run from root of repo directory
Eg:
```
cd ~/Projects/deploy-vpc-aws)
```

## Running Terraform
```
terraform init
terraform get terraform

terraform plan -input=false -state="config/cluster.state" -var "aws_access_key=${AWS_ACCESS_KEY_ID}" -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" -var "aws_region=${AWS_DEFAULT_REGION}" -var "aws_availability_zones=[${AWS_AVAILABILITY_ZONES}]" -var "cluster_config_location=config" -var-file="config/cluster.tfvars" "terraform"

terraform apply -input=false -state="config/cluster.state" -var "aws_access_key=${AWS_ACCESS_KEY_ID}" -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" -var "aws_region=${AWS_DEFAULT_REGION}" -var "aws_availability_zones=[${AWS_AVAILABILITY_ZONES}]" -var "cluster_config_location=config" -var-file="config/cluster.tfvars" "terraform"
```

# Cleanup

```
terraform destroy -input=false -state="config/cluster.state" -var "aws_access_key=${AWS_ACCESS_KEY_ID}" -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" -var "aws_region=${AWS_DEFAULT_REGION}" -var "aws_availability_zones=[${AWS_AVAILABILITY_ZONES}]" -var "cluster_config_location=config" -var-file="config/cluster.tfvars" "terraform"
```
