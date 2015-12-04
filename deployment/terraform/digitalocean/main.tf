# Configure the DigitalOcean Provider
provider "digitalocean" {
    token = "${var.do_apikey}"
}

resource "digitalocean_ssh_key" "apigwperftest" {
    name = "apigwperftest"
    public_key = "${var.sshkey}"
}

resource "digitalocean_droplet" "apiperf" {
    count = "${var.count}"
    image = "centos-7-0-x64"
    private_networking = "True"
    name = "apiperf-${lookup(var.droplet_names, count.index)}"
    size = "${lookup(var.droplet_sizes, count.index)}"
    region = "ams3"
    ssh_keys = [ "${digitalocean_ssh_key.apigwperftest.id}" ]

    provisioner "local-exec" {
        command = "echo ${self.ipv4_address} ${lookup(var.droplet_names, count.index)} > hosts/${lookup(var.droplet_names, count.index)}"
    }
#    provisioner "file" {
#        source = "hosts"
#        destination = "/tmp"
#    }
    provisioner "remote-exec" {
        inline = [
#            "cat /tmp/hosts/* >> /etc/hosts",
            "service firewalld stop"
        ]
    }
}
