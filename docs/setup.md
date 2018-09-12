# Setup Doc

This doc is intended to:

* Help you configure your local tools to interact with remote environment.
* Help you Bootstrap a working VPC environment.
* Terraform instructions will be valid for other projects using this template.
  * Any contradiction of requirements/instructions, use the child templates instructions.

## Basic premise

* Pay attention to versions used. Use latest at your own risk.
* Unless specified, all commands are in bash (Linux/MacOS) or Powershell v4+ (Windows), make sure your package mgmt tool is updated (Eg: `apt-get update`)
* MacOS is assumed to be MacOSX (MacOS 10.12.6 tested)
* Linux is assumed to be Ubuntu 16.04
* Windows is assumed to be Microsoft Windows 10

## Setup Tools

### Setup Terraform

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

## Setup Environment Variables

### Notes

* The Terraform [AWS provider](https://www.terraform.io/docs/providers/aws/index.html) has a few different behaviours, in the current version, however, if you do not specify a set of credentials it will automatically use your default AWS CLI credentials file (Typical location `~/.aws/credentials`).

### Prepare Terraform variables

My preferred method is to create and source a variables file:

* Copy file `~/Projects/deploy-vpc-aws/config/aws_credentials.env.sample` to a new file `~/Projects/deploy-vpc-aws/config/aws_credentials.env.[SOMETHING/YOURNAME/ETC]`
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

## Creating and updating infrastructure

### Notes

* make sure all commands are run from root of repo directory

Eg:

```bash
cd ~/Projects/deploy-vpc-aws)
```

### Running Terraform

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

## Connecting to resources

### Add your generated SSH key to SSH daemon

You need to add the generated SSH key to your SSH daemon, so that you can connect.

```bash
ssh-add config/[YOUR_GENERATED_KEYFILE].key
```

### Connect to Bastion instance

After any apply, there will be instructions of how to connect to the VPC bastion node.
The instruction will show as Template outputs: `_connect_bastion_dns`, `_connect_bastion_ip` and `_connect_bastion_r53`

```bash
_connect_bastion_dns = connect to bastion using: ssh -A ec2-user@ec2-11-12-13-14.eu-west-1.compute.amazonaws.com
_connect_bastion_ip = connect to bastion using: ssh -A ec2-user@11.12.13.14
```

If you are using an AWS Route53 hosted zone, there should also be an instruction to connect using DNS name:

```bash
_connect_bastion_r53 = connect to bastion using: ssh -A ec2-user@kareempoc-vpc-bastion.myr53domain.com
```

### Connect from Bastion instance to ETCD/Controller/Worker instances

First you should check the AWS console, or use AWS CLI to get the list of IPs of your instances.

Once you have your target instance IP, and have connected to your bastion instance, you should be able to directly connect to any node. The nodes will all use the same SSH key-pair, and will authenticate without needing to specify anything.
From the bastion:

```bash
ssh ubuntu@10.11.12.13
```

## Cleanup

### Tear down environment.

This command will tear down the deployed environment.

Note: Remember, if you have deployed any dependant templates ([Hint hint](https://github.com/KptnKMan/deploy-kube)), you should tear those down first.

```bash
terraform destroy -input=false -state="config/cluster.state" -var "cluster_config_location=config" -var-file="config/cluster.tfvars" "terraform"
```

After teardown, you can additionally run the debug_cleanup.sh script if you wish to start fresh (Linux/Mac only).

```bash
. debug_cleanup.sh
```
