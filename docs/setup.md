# Setup Doc

This doc is intended to:

* Help configure your local tools to interact with remote environment.
* Bootstrap a working VPC environment.
* Terraform instructions will be valid for other projects using this template.

## Basic premise

* Pay attention to versions used. Use latest at your own risk.
* Unless specified, all commands are in bash (Linux/MacOS) or Powershell v4+ (Windows), make sure your package mgmt tool is updated (Eg: `apt-get update`)
* MacOS is assumed to be MacOSX (MacOS 10.12.6 tested)
* Linux is assumed to be Ubuntu 16.04
* Windows is assumed to be Microsoft Windows 10

# Setup Tools

## Setup Terraform

Linux:

```bash
curl -L https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip -o /tmp/terraform.zip && unzip -o /tmp/terraform.zip -d /tmp/
sudo mv /tmp/terraform /usr/bin/ && rm -Rf /tmp/terraform.zip
```

MacOS:

```bash
curl -L https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_darwin_amd64.zip -o /tmp/terraform.zip && unzip -o /tmp/terraform.zip -d /tmp/
sudo mv /tmp/terraform /usr/local/bin/ && rm -Rf /tmp/terraform.zip
```

Windows:

```powershell
Invoke-WebRequest -Uri https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_windows_amd64.zip -Outfile $Env:USERPROFILE\Downloads\terraform_0.11.7_windows_amd64.zip
Expand-Archive $HOME\Downloads\terraform_0.11.7_windows_amd64.zip -DestinationPath $env:SystemRoot
```

# Setup Environment Variables

## Prepare Terraform variables

The easiest way is to create and source a variables file:

* Copy file `~/Projects/deploy-vpc-aws/config/aws_credentials.env.sample` to a new file `~/Projects/deploy-vpc-aws/config/aws_credentials.env.[YOUR CREDENTIALS]`
* Update the file with your credentials

Linux/MacOS:

```bash
source aws_credentials.env.[YOUR CREDENTIALS]
```

Alternatively, to configure all variables manually (Needs to be done each time a new CLI window is open):

```bash
export TF_VAR_aws_access_key=AKIYOURACCESSKEYHERE
export TF_VAR_aws_secret_key=kTHISISWHEREYOUPUTYOURAWSSECRETKEYHEREt1
export TF_VAR_aws_region=eu-central-1
export TF_VAR_aws_availability_zones=$(aws ec2 describe-availability-zones --output text | awk '{print "\""$4"\""};' | tr '\n' ',' | sed 's/,*$//g')
```

Windows:

```powershell
Get-Content $HOME\Projects\deploy-vpc-aws\aws_credentials.env.[YOUR CREDENTIALS] | ForEach-Object { "$_"; $var = $_.Split('='); New-Variable -Name $var[0] -Value $var[1] -Scope Global }
function get-zones-short { $aws_zones_raw = @(); (aws ec2 describe-availability-zones) -split "\s" | ForEach-Object {$aws_zones_raw += Select-String -InputObject $_ -Pattern '([a-z]+-[a-z]+-[0-9][a-z])'}; $aws_zones1 = $aws_zones_raw  -replace '"','' -replace ',',''; $aws_zones2 = $aws_zones1 -join '\",\"'; $Global:AWS_ZONES = $aws_zones1 -join ','; $Global:AWS_AVAILABILITY_ZONES = '\"'+$aws_zones2+'\"' } get-zones-short; $Global:AWS_AVAILABILITY_ZONES
```

# Creating and updating infrastructure

## Notes

* make sure all commands are run from root of repo directory

Eg:

```bash
cd ~/Projects/deploy-vpc-aws)
```

## Running Terraform

You need to initialise the environment before you can deploy.
This will download any modules and provisioners you need.

```bash
terraform init terraform
terraform get terraform
```

This is an optional step to display changes, without the intention to apply them now.
Useful for planning changes and checking for template errors.

```bash
terraform plan -input=false -state="config/cluster.state" -var "cluster_config_location=config" -var-file="config/cluster.tfvars" "terraform"
```

This is where we're cooking with gas, applying our desired state to the remote environment(s).

```bash
terraform apply -input=false -state="config/cluster.state" -var "cluster_config_location=config" -var-file="config/cluster.tfvars" "terraform"
```

# Connecting to resources

## Add your generated SSH key to SSH daemon

```bash
ssh-add config/[YOUR_GENERATED_KEYFILE].key
```

# Cleanup

## Tear down environment.

This command will tear down the deployed environment.
Note: Remember, if you have deployed any dependant templates ([Hint hint](https://github.com/KptnKMan/deploy-kube)), you should tear those down first.

```bash
terraform destroy -input=false -state="config/cluster.state" -var "cluster_config_location=config" -var-file="config/cluster.tfvars" "terraform"
```
