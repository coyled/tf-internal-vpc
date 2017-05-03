provider "aws" {
    region = "${var.aws_region}"
}

resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"

    tags {
        Name = "${var.cluster_name}"
    }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.vpc.id}"

    tags {
        Name = "${var.cluster_name} igw"
    }
}

resource "aws_eip" "nat_eip" {
    count    = "${length(var.public_ranges)}"
    vpc = true
}

resource "aws_nat_gateway" "gw" {
    count = "${length(var.public_ranges)}"
    allocation_id = "${aws_eip.nat_eip.*.id[count.index]}"
    subnet_id = "${aws_subnet.public.*.id[count.index]}"

    depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_subnet" "public" {
    vpc_id = "${aws_vpc.vpc.id}"
    count = "${length(var.public_ranges)}"
    cidr_block = "${var.public_ranges[count.index]}"
    availability_zone = "${var.aws_region}${var.azs[count.index]}"
    map_public_ip_on_launch = "true"

    tags {
        Name = "${var.cluster_name} ${var.aws_region}${var.azs[count.index]} public"
    }
}

resource "aws_subnet" "private" {
    vpc_id = "${aws_vpc.vpc.id}"
    count = "${length(var.private_ranges)}"
    cidr_block = "${var.private_ranges[count.index]}"
    availability_zone = "${var.aws_region}${var.azs[count.index]}"
    map_public_ip_on_launch = "false"

    tags {
        Name = "${var.cluster_name} ${var.aws_region}${var.azs[count.index]} private"
    }
}

resource "aws_route_table" "private" {
    vpc_id = "${aws_vpc.vpc.id}"
    count = "${length(var.private_ranges)}"

    tags { 
        Name = "${var.cluster_name} route table ${var.aws_region}${var.azs[count.index]} private"
    }
}

resource "aws_route_table" "public" {
    vpc_id = "${aws_vpc.vpc.id}"
    count = "${length(var.public_ranges)}"

    tags { 
        Name = "${var.cluster_name} route table ${var.aws_region}${var.azs[count.index]} public"
    }
}

resource "aws_route_table_association" "private" {
    count = "${length(var.private_ranges)}"
    subnet_id = "${aws_subnet.private.*.id[count.index]}"
    route_table_id = "${aws_route_table.private.*.id[count.index]}"
}

resource "aws_route_table_association" "public" {
    count = "${length(var.public_ranges)}"
    subnet_id = "${aws_subnet.public.*.id[count.index]}"
    route_table_id = "${aws_route_table.public.*.id[count.index]}"
}

resource "aws_route" "ngw" {
    nat_gateway_id = "${aws_nat_gateway.gw.*.id[count.index]}"
    count = "${length(var.private_ranges)}"
    route_table_id = "${aws_route_table.private.*.id[count.index]}"
    destination_cidr_block = "0.0.0.0/0"

    depends_on = ["aws_route_table.private"]
}

resource "aws_route" "igw" {
    gateway_id = "${aws_internet_gateway.gw.id}"
    count = "${length(var.public_ranges)}"
    route_table_id = "${aws_route_table.public.*.id[count.index]}"
    destination_cidr_block = "0.0.0.0/0"

    depends_on = ["aws_route_table.public"]
}
