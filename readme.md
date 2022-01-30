## Overview
* This repo contains the 

## Prerequisites
terraform <= 1.1.2
terragrunt = v0.35.16

## Directories

#### tf_bootstrap
* Contains terraform code that needs to be deployed manually to create the remote state needed for the rest of the global infrastructure

#### vpc
* contains vpc related terraform. wip. will rename to `network` in the future

## TODO:
* Create modules folder for other projects to source from
* Possibly automate the deployment of global infrastructure
* strengthen the security of VPC
* Add internet gateway
* Use tagging to control release management of the modules
* Be able to deploy an app that uses the cicd module. The app is a serverless app that makes use of the vpc that has been deployed
