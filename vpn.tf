data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-yakkety-16.10-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

resource "aws_instance" "vpn" {
    ami           = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"

    disable_api_termination = "true"
    key_name = "${var.ssh_key_name}"
    vpc_security_group_ids = ["${aws_security_group.vpn.id}"]
    subnet_id = "${aws_subnet.public.0.id}"

    tags {
        Name = "${var.cluster_name} - vpn"
    }
}

resource "aws_security_group" "vpn" {
    name = "${var.cluster_name} - vpn endpoint"
    description = "allow connections from the world to VPN services"
    vpc_id = "${aws_vpc.vpc.id}"

    ingress {
        from_port = 0
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    ingress {
        from_port = 0
        to_port = 500
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    ingress {
        from_port = 0
        to_port = 4500
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    } 

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}
