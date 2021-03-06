#!/bin/bash

## Delete existing current certs
rm -Rf config/ssl
rm -Rf config/*.key
rm -Rf config/*.pub
rm -Rf config/*.ssh

## Delete terraform state files
rm -Rf terraform.tfstate
rm -Rf terraform.tfstate.backup
