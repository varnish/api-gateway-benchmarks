# Configure the Amazon EC2 Provider
provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_ec2_region}"
}

# Create a key pair
resource "aws_key_pair" "apiperf-sshkey" {
    key_name = "apiperf-sshkey" 
    public_key = "${var.sshkey}"
}

# Create a VPC
resource "aws_vpc" "apiperf" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
}

# Create an internet gateway to give the subnet access to the world
resource "aws_internet_gateway" "apiperf" {
    vpc_id = "${aws_vpc.apiperf.id}"
}

# Grant VPC internet access on its main route table
resource "aws_route" "apiperf-internet_access" {
    route_table_id         = "${aws_vpc.apiperf.main_route_table_id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = "${aws_internet_gateway.apiperf.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "apiperf" {
    vpc_id                  = "${aws_vpc.apiperf.id}"
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = true
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "apiperf" {
  name        = "api_engine_perftests"
  description = "Used for API Engine Performance Testing"
  vpc_id      = "${aws_vpc.apiperf.id}"

  # Permit ICMP
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Testing Ports
  ingress {
    from_port   = 0
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 6081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "apiperf-gateway" {
    ami = "${lookup(var.aws_ec2_ami, "gateway")}"
    instance_type = "${lookup(var.instance_types, "gateway")}"
    key_name = "apiperf-sshkey"
    user_data = "${file("aws-ec2/userdata.sh")}"
    subnet_id              = "${aws_subnet.apiperf.id}"
    vpc_security_group_ids = ["${aws_security_group.apiperf.id}"]
    tags {
        name = "${lookup(var.instance_names, "gateway")}"
    }
    provisioner "local-exec" {
        command = "echo ${self.private_ip} ${lookup(var.instance_names, "gateway")} > hosts/${lookup(var.instance_names, "gateway")}.host"
    }
    provisioner "local-exec" {
        command = "echo ansible_ssh_user: ${lookup(var.user_name, aws_instance.apiperf-gateway.ami)} > host_vars/${self.public_ip}"
    }
}

resource "aws_instance" "apiperf-webserver" {
    ami = "${lookup(var.aws_ec2_ami, "webserver")}"
    instance_type = "${lookup(var.instance_types, "webserver")}"
    key_name = "apiperf-sshkey"
    user_data = "${file("aws-ec2/userdata.sh")}"
    subnet_id              = "${aws_subnet.apiperf.id}"
    vpc_security_group_ids = ["${aws_security_group.apiperf.id}"]
    tags {
        name = "${lookup(var.instance_names, "webserver")}"
    }
    provisioner "local-exec" {
        command = "echo ${self.private_ip} ${lookup(var.instance_names, "webserver")} > hosts/${lookup(var.instance_names, "webserver")}.host"
    }
    provisioner "local-exec" {
        command = "echo ansible_ssh_user: ${lookup(var.user_name, aws_instance.apiperf-webserver.ami)} > host_vars/${self.public_ip}"
    }
}

resource "aws_instance" "apiperf-consumer" {
    ami = "${lookup(var.aws_ec2_ami, "consumer")}"
    instance_type = "${lookup(var.instance_types, "consumer")}"
    key_name = "apiperf-sshkey"
    user_data = "${file("aws-ec2/userdata.sh")}"
    subnet_id              = "${aws_subnet.apiperf.id}"
    vpc_security_group_ids = ["${aws_security_group.apiperf.id}"]
    tags {
        name = "${lookup(var.instance_names, "consumer")}"
    }
    provisioner "local-exec" {
        command = "echo ${self.private_ip} ${lookup(var.instance_names, "consumer")} > hosts/${lookup(var.instance_names, "consumer")}.host"
    }
    provisioner "local-exec" {
        command = "echo ansible_ssh_user: ${lookup(var.user_name, aws_instance.apiperf-consumer.ami)} > host_vars/${self.public_ip}"
    }
}

resource "null_resource" "hostsfile" {
    triggers {
        aws_instance_consumer  = "${aws_instance.apiperf-consumer.private_ip}"
        aws_instance_webserver = "${aws_instance.apiperf-webserver.private_ip}"
        aws_instance_gateway   = "${aws_instance.apiperf-gateway.private_ip}"
    }
    provisioner "file" {
        connection {
            host = "${aws_instance.apiperf-consumer.public_ip}"
            user = "${lookup(var.user_name, aws_instance.apiperf-consumer.ami)}"
        }
        source = "hosts"
        destination = "/tmp"
    }
    provisioner "remote-exec" {
        connection {
            host = "${aws_instance.apiperf-consumer.public_ip}"
            user = "${lookup(var.user_name, aws_instance.apiperf-consumer.ami)}"
        }
        inline = [
            "sudo sh -c 'cat /tmp/hosts/hostsheader /tmp/hosts/*.host > /etc/hosts'",
        ]
    }
    provisioner "file" {
        connection {
            host = "${aws_instance.apiperf-gateway.public_ip}"
            user = "${lookup(var.user_name, aws_instance.apiperf-gateway.ami)}"
        }
        source = "hosts"
        destination = "/tmp"
    }
    provisioner "remote-exec" {
        connection {
            host = "${aws_instance.apiperf-gateway.public_ip}"
            user = "${lookup(var.user_name, aws_instance.apiperf-gateway.ami)}"
        }
        inline = [
            "sudo sh -c 'cat /tmp/hosts/hostsheader /tmp/hosts/*.host > /etc/hosts'",
        ]
    }
    provisioner "file" {
        connection {
            host = "${aws_instance.apiperf-webserver.public_ip}"
            user = "${lookup(var.user_name, aws_instance.apiperf-webserver.ami)}"
        }
        source = "hosts"
        destination = "/tmp"
    }
    provisioner "remote-exec" {
        connection {
            host = "${aws_instance.apiperf-webserver.public_ip}"
            user = "${lookup(var.user_name, aws_instance.apiperf-webserver.ami)}"
        }
        inline = [
            "sudo sh -c 'cat /tmp/hosts/hostsheader /tmp/hosts/*.host > /etc/hosts'",
        ]
    }
}

