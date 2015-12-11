# Configure the DigitalOcean Provider
provider "digitalocean" {
    token = "${var.do_apikey}"
}

resource "digitalocean_ssh_key" "apiperf-sshkey" {
    name = "apigwperftest"
    public_key = "${var.sshkey}"
}

resource "digitalocean_droplet" "apiperf-webserver" {
    image = "${var.droplet_image}"
    private_networking = "${var.droplet_use_privatenet}"
    name = "apiperf-${lookup(var.droplet_names, "webserver")}"
    size = "${lookup(var.droplet_sizes, "webserver")}"
    region = "${var.droplet_region}"
    ssh_keys = [ "${digitalocean_ssh_key.apiperf-sshkey.id}" ]
    provisioner "local-exec" {
        command = "echo ${self.ipv4_address} ${lookup(var.droplet_names, "webserver")} > hosts/${lookup(var.droplet_names, "webserver")}"
    }
    provisioner "remote-exec" {
        inline = [
            "service firewalld stop"
        ]
    }
}

resource "digitalocean_droplet" "apiperf-gateway" {
    image = "${var.droplet_image}"
    private_networking = "${var.droplet_use_privatenet}"
    name = "apiperf-${lookup(var.droplet_names, "gateway")}"
    size = "${lookup(var.droplet_sizes, "gateway")}"
    region = "${var.droplet_region}"
    ssh_keys = [ "${digitalocean_ssh_key.apiperf-sshkey.id}" ]
    provisioner "local-exec" {
        command = "echo ${self.ipv4_address} ${lookup(var.droplet_names, "gateway")} > hosts/${lookup(var.droplet_names, "gateway")}"
    }
    provisioner "remote-exec" {
        inline = [
            "service firewalld stop"
        ]
    }
}

resource "digitalocean_droplet" "apiperf-consumer" {
    image = "${var.droplet_image}"
    private_networking = "${var.droplet_use_privatenet}"
    name = "apiperf-${lookup(var.droplet_names, "consumer")}"
    size = "${lookup(var.droplet_sizes, "consumer")}"
    region = "${var.droplet_region}"
    ssh_keys = [ "${digitalocean_ssh_key.apiperf-sshkey.id}" ]
    provisioner "local-exec" {
        command = "echo ${self.ipv4_address} ${lookup(var.droplet_names, "consumer")} > hosts/${lookup(var.droplet_names, "consumer")}"
    }
    provisioner "remote-exec" {
        inline = [
            "service firewalld stop"
        ]
    }
}

resource "null_resource" "hostsfile" {
    triggers {
        droplet_consumer  = "${digitalocean_droplet.apiperf-consumer.ipv4_address}"
        droplet_webserver = "${digitalocean_droplet.apiperf-webserver.ipv4_address}"
        droplet_gateway   = "${digitalocean_droplet.apiperf-gateway.ipv4_address}"
    }
    provisioner "file" {
        connection {
            host = "${digitalocean_droplet.apiperf-consumer.ipv4_address}"
        }
        source = "hosts"
        destination = "/tmp"
    }
    provisioner "remote-exec" {
        connection {
            host = "${digitalocean_droplet.apiperf-consumer.ipv4_address}"
        }
        inline = [
            "cat /tmp/hostsheader /tmp/hosts/*.host > /etc/hosts'",
        ]
    }
    provisioner "file" {
        connection {
            host = "${digitalocean_droplet.apiperf-gateway.ipv4_address}"
        }
        source = "hosts"
        destination = "/tmp"
    }
    provisioner "remote-exec" {
        connection {
            host = "${digitalocean_droplet.apiperf-gateway.ipv4_address}"
        }
        inline = [
            "cat /tmp/hostsheader /tmp/hosts/*.host > /etc/hosts'",
        ]
    }
    provisioner "file" {
        connection {
            host = "${digitalocean_droplet.apiperf-webserver.ipv4_address}"
        }
        source = "hosts"
        destination = "/tmp"
    }
    provisioner "remote-exec" {
        connection {
            host = "${digitalocean_droplet.apiperf-webserver.ipv4_address}"
        }
        inline = [
            "cat /tmp/hostsheader /tmp/hosts/*.host > /etc/hosts'",
        ]
    }
}
