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
    user_data = "${file("aws-ec2/userdata.sh")}"
    tags {
        name = "${lookup(var.instance_names, count.index)}"
    }
    provisioner "local-exec" {
        command = "echo ${self.private_ip} ${lookup(var.instance_names, count.index)} > hosts/${lookup(var.instance_names, count.index)}"
    }
#    provisioner "file" {
#        connection {
#            user = "centos"
#        }
#        source = "hosts"
#        destination = "/tmp"
#    }
#    provisioner "remote-exec" {
#        connection {
#            user = "centos"
#        }
#        inline = [
#            "sudo cp /etc/hosts /tmp/newhostsfile",
#            "sudo chown centos /tmp/newhostsfile",
#            "cat /tmp/hosts/* >> /tmp/newhostsfile",
#            "sudo cp /tmp/newhostsfile /etc/hosts",
#            "sudo chown root /etc/hosts"
#        ]
#    }
}
