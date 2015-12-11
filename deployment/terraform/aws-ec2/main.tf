# Configure the Amazon EC2 Provider
provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_ec2_region}"
}

resource "aws_key_pair" "apiperf-sshkey" {
    key_name = "apiperf-sshkey" 
    public_key = "${var.sshkey}"
}

resource "aws_instance" "apiperf-gateway" {
    ami = "${var.aws_ec2_ami}"
    instance_type = "${lookup(var.instance_types, "gateway")}"
    key_name = "apiperf-sshkey"
    user_data = "${file("aws-ec2/userdata.sh")}"
    tags {
        name = "${lookup(var.instance_names, "gateway")}"
    }
    provisioner "local-exec" {
        command = "echo ${self.private_ip} ${lookup(var.instance_names, "gateway")} > hosts/${lookup(var.instance_names, "gateway")}.host"
    }
}

resource "aws_instance" "apiperf-webserver" {
    ami = "${var.aws_ec2_ami}"
    instance_type = "${lookup(var.instance_types, "webserver")}"
    key_name = "apiperf-sshkey"
    user_data = "${file("aws-ec2/userdata.sh")}"
    tags {
        name = "${lookup(var.instance_names, "webserver")}"
    }
    provisioner "local-exec" {
        command = "echo ${self.private_ip} ${lookup(var.instance_names, "webserver")} > hosts/${lookup(var.instance_names, "webserver")}.host"
    }
}

resource "aws_instance" "apiperf-consumer" {
    ami = "${var.aws_ec2_ami}"
    instance_type = "${lookup(var.instance_types, "consumer")}"
    key_name = "apiperf-sshkey"
    user_data = "${file("aws-ec2/userdata.sh")}"
    tags {
        name = "${lookup(var.instance_names, "consumer")}"
    }
    provisioner "local-exec" {
        command = "echo ${self.private_ip} ${lookup(var.instance_names, "consumer")} > hosts/${lookup(var.instance_names, "consumer")}.host"
    }
}

resource "null_resource" "hostsfile" {
    triggers {
        aws_instance_consumer  = "${aws_instance.apiperf-consumer.private_ip}"
        aws_instance_webserver = "${aws_instance.apiperf-webserver.private_ip}"
        aws_instance_gateway   = "${aws_instance.apiperf-gateway.private_ip}"
    }
    connection {
        user = "centos"
    }
    provisioner "file" {
        connection {
            host = "${aws_instance.apiperf-consumer.public_ip}"
        }
        source = "hosts"
        destination = "/tmp"
    }
    provisioner "remote-exec" {
        connection {
            host = "${aws_instance.apiperf-consumer.public_ip}"
        }
        inline = [
            "sudo sh -c 'cat /tmp/hosts/hostsheader /tmp/hosts/*.host > /etc/hosts'",
        ]
    }
    connection {
        user = "centos"
        host = "${aws_instance.apiperf-gateway.public_ip}"
    }
    provisioner "file" {
        connection {
            host = "${aws_instance.apiperf-gateway.public_ip}"
        }
        source = "hosts"
        destination = "/tmp"
    }
    provisioner "remote-exec" {
        connection {
            host = "${aws_instance.apiperf-gateway.public_ip}"
        }
        inline = [
            "sudo sh -c 'cat /tmp/hosts/hostsheader /tmp/hosts/*.host > /etc/hosts'",
        ]
    }
    provisioner "file" {
        connection {
            host = "${aws_instance.apiperf-webserver.public_ip}"
        }
        source = "hosts"
        destination = "/tmp"
    }
    provisioner "remote-exec" {
        connection {
            host = "${aws_instance.apiperf-webserver.public_ip}"
        }
        inline = [
            "sudo sh -c 'cat /tmp/hosts/hostsheader /tmp/hosts/*.host > /etc/hosts'",
        ]
    }
}

