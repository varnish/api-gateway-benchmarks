# Terraform based deploys

## Installing Terraform

Terraform is a Golang based tool and official binaries are available at https://terraform.io/downloads.html.
On OSX, Terraform can also be installed via Homebrew.

## Important information

Terraform manipulates cloud based instances, and it is imperative that you ensure that the configuration used does not alter any of your existing resources. Typically the naming chosen for the instances should avoid this, but please ensure via ``terraform plan`` before applying or destroying.

## Amazon EC2

### Quickstart EC2

1. Edit the terraform.tfvars file and insert AWS credentials and sshkey
2. Run ``terraform plan aws-ec2`` to verify the plan
3. Run ``terraform apply aws-ec2`` to spin up instances
4. XXX: insert provisioning instructions here
5. Run ``terraform destroy aws-ec2`` to remove all resources

### Nodes

The default is to start 3 instances:

* webserver
* gateway
* consumer

### Custom setups

The instance types and ami to use is configured in ``aws-ec2/vars.tf``, default is **m3.medium** and the official Centos7 AMI.

## DigitalOcean

### Quickstart DigitalOcean

1. Edit the terraform.tfvars file and insert a valid API key and sshkey
2. Run ``terraform plan digitalocean`` to verify the plan
3. Run ``terraform apply digitalocean`` to spin up instances
4. XXX: insert provisioning instructions here
5. Run ``terraform destroy digitalocean`` to remove all resources

