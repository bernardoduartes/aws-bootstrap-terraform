resource "aws_vpc" "main-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.app_name}-vpc"
  }
}

resource "aws_subnet" "subnets" {
    count = 2
    vpc_id  = aws_vpc.main-vpc.id
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.available.names[count.index]
    cidr_block = "10.0.${count.index}.0/24"
    tags = {
        Name = "${var.app_name}-subnet-${count.index}"
    }
}

resource "aws_internet_gateway" "new-igw" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name = "${var.app_name}-igw"
  }
}

resource "aws_route_table" "new-rtb" {
  vpc_id = aws_vpc.main-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.new-igw.id
  }
  tags = {
    Name = "${var.app_name}-rtb"
  }
}

resource "aws_route_table_association" "new-rtb-association" {
  count = 2
  route_table_id = aws_route_table.new-rtb.id
  subnet_id = aws_subnet.subnets.*.id[count.index]
}

data "aws_availability_zones" "available" {}
output "aws_available_zones_output" {
  value   = "${data.aws_availability_zones.available.names}"
}

output "aws_used_subnets" {
  value   = aws_subnet.subnets
}

#resource "aws_subnet" "main-vpc-subnet-2" {
#    availability_zone = "us-east-1b"
#    vpc_id     = aws_vpc.main-vpc.id
#    cidr_block = "10.0.1.0/24"
#    tags = {
#        Name = "${var.app_name}-subnet-2"
#    }
#}

