# Description

This repository contains Kareems Terraform VPC configuration.
It's designed to be a basis for other repos based on Terraform to use as an output Eg: [Kareems New Kubernetes Deployment configuration](https://github.com/KptnKMan/deploy-kube).
This is intended to eventually reflect production-ready implementation.
Currently it is in testing, and may not work.

It contains:

* (WIP) Documentation for setup and management
* (WIP) Deployment VPC, Subnets, Routes, etc
* (WIP) Bastion EC2 server and Security Group
* (TBC) Default configuration and settings to build environment

Additional documentation for setup can be found in [docs](docs), when they become available.

Best to start at the [Setup doc](docs/setup.md) to setup an environment.

## Basic Requirements

* Terraform 0.11.7
* ~~an ssh public/private keypair in /config dir~~
  * a key will be auto-generated into the /config dir

## Main Components

AWS

* VPC
* Internet Gateway
* Route Tables
* Subnets
* S3 Buckets
* Route53 DNS
* 2x Security Group
  * common-sg - SG for all instances, basic universal rules
  * bastion-sg - SG for bastion, access to all nodes
* 1x EC2 Spot Instance (Bastion host)

## Notes

Versions tested:

* terraform: 0.8.8 upto 0.11.7

Terraform Outputs:

* this template will output a number of properties that are intended to be used with dependent templates.

## Todos & Known issues

* [x] update terraform to latest 10.x+
* [x] Fix some terraform code inconstencies
* [x] Instance ssh-keypair auto-generation
