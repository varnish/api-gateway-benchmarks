# Configure the Amazon EC2 Provider
provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_ec2_region}"
}

resource "aws_key_pair" "apiperftestkey" {
    key_name = "apiperftestkey" 
    public_key = "${var.sshkey}"
}

resource "aws_instance" "apiperf" {
    count = "${var.count}"
    ami = "${var.aws_ec2_ami}"
    instance_type = "${lookup(var.instance_types, count.index)}"
    key_name = "apiperftestkey"
    tags {
        name = "${lookup(var.instance_names, count.index)}"
    }
    provisioner "local-exec" {
        command = "echo ${self.private_ip} ${lookup(var.instance_names, count.index)} > hoststmp/${lookup(var.instance_names, count.index)}"
    }
    provisioner "file" {
        connection {
            user = "centos"
        }
        source = "hoststmp"
        destination = "/tmp"
    }
    provisioner "remote-exec" {
        connection {
            user = "centos"
        }
        inline = [
            "sudo cat /tmp/hoststmp/* >> /etc/hosts",
            "sudo service firewalld stop"
        ]
    }
}
