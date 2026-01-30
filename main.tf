resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = var.vpc_name
    }  
}
resource "aws_subnet" "subnets" {
    count = length(data.aws_availability_zones.azs.names)
    cidr_block = "10.0.${count.index+1}.0/24"
    tags = {
        Name = "${var.vpc_name}-subnet-${count.index+1}"
    }
    availability_zone = data.aws_availability_zones.azs.names[count.index]
    vpc_id = aws_vpc.vpc.id
  
}