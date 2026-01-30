resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = var.vpc_name
    }  
}
resource "aws_subnet" "pub-subnets" {
    count = length(data.aws_availability_zones.azs.names)
    cidr_block = "10.0.${count.index+1}.0/24"
    tags = {
        Name = "${var.vpc_name}-pub-subnet-${count.index+1}"
    }
    availability_zone = data.aws_availability_zones.azs.names[count.index]
    vpc_id = aws_vpc.vpc.id
  
}
resource "aws_subnet" "pvt-subnets" {
    count = length(data.aws_availability_zones.azs.names)
    cidr_block = "10.0.${count.index+11}.0/24"
    tags = {
        Name = "${var.vpc_name}-pvt-subnet-${count.index+1}"
    }
    availability_zone = data.aws_availability_zones.azs.names[count.index]
    vpc_id = aws_vpc.vpc.id
  
}
resource "aws_internet_gateway" "vpc-ig" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "${var.vpc_name}-ig"
    }
  
}
resource "aws_default_route_table" "def-rt-vpc" {
    default_route_table_id = aws_vpc.vpc.default_route_table_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.vpc-ig.id
    }
    tags = {
      Name = "${var.vpc_name}-def-rt"
    }
}

resource "aws_route_table" "pvt-rt" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "${var.vpc_name}-pvt-rt"
    }
  
}
resource "aws_route_table_association" "pvt-rt-association" {
    count = length(data.aws_availability_zones.azs.names)
    subnet_id = aws_subnet.pvt-subnets[count.index].id
    route_table_id = aws_route_table.pvt-rt.id
  
}
resource "aws_security_group" "vpc-sg-frotend" {
    name       = "${var.vpc_name}-sg-frontend"
    description = "Security group for frontend servers"
    vpc_id      = aws_vpc.vpc.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }   
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}