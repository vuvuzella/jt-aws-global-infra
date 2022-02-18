#------------------------------------------------
# Internet gateway for the VPC
#------------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id =  aws_vpc.jt_aws_vpc_main.id
  tags = {
    Name = "jt_aws_vpc_igw"
  }
}


#------------------------------------------------
# Public NAT gateway (web-2a)
#------------------------------------------------
resource "aws_nat_gateway" "nat_public_web_2a" {
  allocation_id = aws_eip.web_2a.id
  subnet_id = aws_subnet.web-public-2a.id

  tags = {
    Name = "jt-vpc-nat-public-web-2a"
  }

  depends_on = [aws_internet_gateway.igw]
}

#------------------------------------------------
# Allocate 1 Elastic IP (EIP) Address
#------------------------------------------------
resource "aws_eip" "web_2a" {
  vpc = true
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "jt-aws-eip-web_2a"
  }
}

#------------------------------------------------
# Route table for web-2a to igw
#------------------------------------------------
resource "aws_route_table" "nat_route_igw" {
  vpc_id = aws_vpc.jt_aws_vpc_main.id
  
  // route = [] # to remove all routes, uncomment this and comment out the other route blocks

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "jt-aws-rt-web-2a"
  }

}

resource "aws_route_table_association" "rt-web-2a" {
  route_table_id = aws_route_table.nat_route_igw.id
  subnet_id = aws_subnet.web-public-2a.id
}

#------------------------------------------------
# Route table for app-2a 
#------------------------------------------------
resource "aws_route_table" "app_2a_nat" {
  vpc_id = aws_vpc.jt_aws_vpc_main.id

  // route = [] # to remove all routes, uncomment this and comment out the other route blocks

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_public_web_2a.id
  }

  tags = {
    Name = "jt-aws-rt-app-2a"
  }
}

resource "aws_route_table_association" "rt-app-2a" {
  route_table_id = aws_route_table.app_2a_nat.id
  subnet_id = aws_subnet.app-private-apse2[0].id
}
