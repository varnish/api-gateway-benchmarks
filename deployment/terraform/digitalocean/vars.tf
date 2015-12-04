variable "do_apikey" {
    description = "Valid Digital Ocean API Key"
}
variable "sshkey" {
    description = "SSH key to use for provisioning"
}
variable "count" {
    description = "Number of droplets to create"
    default = "3"
}

variable "droplet_names" {
    description = "Base names to use for droplets"
    default = {
        "0" = "gateway"
        "1" = "webserver"
        "2" = "consumer"
    }
}

variable "droplet_sizes" {
    description = "Droplet sizes"
    default = {
        "0" = "1gb"
        "1" = "512mb"
        "2" = "512mb"
    }
}
