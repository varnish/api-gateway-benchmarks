variable "aws_access_key" {
    description = "Valid Amazon AWS access key"
}
variable "aws_secret_key" {
    description = "Valid Amazon AWS secret key"
}
# http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html
variable "aws_ec2_region" {
    description = "Amazon EC2 region to use"
    default = "us-east-1"
}
# https://aws.amazon.com/marketplace/pp/B00O7WM7QW 
variable "aws_ec2_ami" {
    description = "The EC2 AMI to use"
    default = "ami-61bbf104"
}
variable "sshkey" {
    description = "SSH key to use for provisioning"
}
variable "count" {
    description = "Number of instances to create"
    default = "3"
}

variable "instance_names" {
    description = "Base names to use for instances"
    default = {
        "0" = "gateway"
        "1" = "webserver"
        "2" = "consumer"
    }
}

# https://aws.amazon.com/ec2/instance-types/ 
variable "instance_types" {
    description = "Instance types to use"
    default = {
        "0" = "m3.medium"
        "1" = "m3.medium"
        "2" = "m3.medium"
    }
}
