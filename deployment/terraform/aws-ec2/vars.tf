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
    default = {
        "gateway"   = "ami-6d1c2007"
        "webserver" = "ami-6d1c2007"
        "consumer"  = "ami-6d1c2007"
    }
}

variable "sshkey" {
    description = "SSH key to use for provisioning"
}

variable "instance_names" {
    description = "Base names to use for instances"
    default = {
        "gateway"   = "gateway"
        "webserver" = "webserver"
        "consumer"  = "consumer"
    }
}

# https://aws.amazon.com/ec2/instance-types/ 
variable "instance_types" {
    description = "Instance types to use"
    default = {
        "gateway"   = "m3.medium"
        "webserver" = "m3.medium"
        "consumer"  = "m3.medium"
    }
}

variable "user_name" {
    default = {
        "ami-6d1c2007" = "centos"
    }
}
