variable "aws_region" {
    type = "string"
}

variable "cluster_name" {
    type = "string"
}

variable "public_ranges" {
    type = "list"
}

variable "private_ranges" {
    type = "list"
}

variable "azs" {
    type = "list"
}

variable "ssh_key_name" {
    type = "string"
}
