variable "do_apikey" {
    description = "Valid Digital Ocean API Key"
}

variable "sshkey" {
    description = "SSH key to use for provisioning"
}

variable "droplet_region" {
    description = "The region to use for droplets"
    default = "ams3"
}

variable "droplet_image" {
    description = "The droplet image to use"
    default = "centos-7-0-x64"
}

variable "droplet_use_privatenet" {
    description = "Disable or enable private networking"
    default = "False"
}

variable "droplet_names" {
    description = "Base names to use for droplets"
    default = {
        "gateway"   = "gateway"
        "webserver" = "webserver"
        "consumer"  = "consumer"
    }
}

variable "droplet_sizes" {
    description = "Droplet sizes"
    default = {
        "gateway"   = "1gb"
        "webserver" = "512mb"
        "consumer"  = "512mb"
    }
}
