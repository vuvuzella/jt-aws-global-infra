/**********************************************************
 *
 * VPC DATA
 *
 **********************************************************/
data "aws_availability_zones" "az-2a" {
  all_availability_zones = true
  filter {
    name = "zone-name"
    values = ["ap-southeast-2a"]
  }
}

data "aws_availability_zones" "az-2b" {
  all_availability_zones = true
  filter {
    name = "zone-name"
    values = ["ap-southeast-2b"]
  }
}

data "aws_availability_zones" "az-2c" {
  all_availability_zones = true
  filter {
    name = "zone-name"
    values = ["ap-southeast-2c"]
  }
}

data "aws_availability_zones" "all_azs" {
  all_availability_zones = true
}

/**********************************************************
 * VPC CONFIGURATION
 * 10.20.0.0/16 (65536 gross ip addresses)
 **********************************************************/
resource "aws_vpc" "jt_aws_vpc_main" {
  cidr_block = "10.20.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = false
  tags = {
    "Name" = "jt_aws_vpc_main"
  }
}

/**********************************************************
 *
 * VPC SECURITY GROUP CONFIGURATION
 *
 **********************************************************/
resource "aws_default_security_group" "egress_only" {
  // name = "jt-aws-egress-only"
  // description = "An egress only security group for jt_aws_vpc_main"
  vpc_id = aws_vpc.jt_aws_vpc_main.id
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["10.20.0.0/16"]
  }

  tags = {
    "Name" = "jt_aws_vpc_main_default_sg"
  }
}

/**********************************************************
 * WEB TIER
 * PUBLIC SUBNET CONFIGURATION
 * ALL PUBLIC SUBNET CIDR BLOCK: 10.20.64.0/18
 * 3 availability zones in ap-southeast-2
 **********************************************************/
resource "aws_subnet" "web-public-2a" {
  vpc_id = aws_vpc.jt_aws_vpc_main.id
  cidr_block = "10.20.64.0/20"
  availability_zone_id = data.aws_availability_zones.az-2a.zone_ids[0]
  tags = {
    Name = "web-public-2a"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "web-public-2b" {
  vpc_id = aws_vpc.jt_aws_vpc_main.id
  cidr_block = "10.20.80.0/20"
  availability_zone_id = data.aws_availability_zones.az-2b.zone_ids[0]
  tags = {
    Name = "web-public-2b"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "web-public-2c" {
  vpc_id = aws_vpc.jt_aws_vpc_main.id
  cidr_block = "10.20.96.0/20"
  availability_zone_id = data.aws_availability_zones.az-2c.zone_ids[0]
  tags = {
    Name = "web-public-2c"
  }

  lifecycle {
    create_before_destroy = true
  }
}

/**********************************************************
 * APP TIER
 * PRIVATE SUBNET CONFIGURATION
 * ALL PRIVATE SUBNET CIDR BLOCK: 10.20.128.0/18
 * 3 availability zones in ap-southeast-2
 **********************************************************/
resource "aws_subnet" "app-private-apse2" {
  // { 0 => [az_name, az_id], ...}
  for_each = { for index,tuple in
                [ for name,id in zipmap(data.aws_availability_zones.all_azs.names,
                                        data.aws_availability_zones.all_azs.zone_ids)
                    : [name, id]
                ] : index => tuple }
    vpc_id = aws_vpc.jt_aws_vpc_main.id
    cidr_block = "10.20.${128 + (16 * each.key)}.0/20"
    availability_zone_id = each.value[1]
    tags = {
      Name = "app-private-${each.value[0]}"
    }
    lifecycle {
      create_before_destroy = true
    }
}

/**********************************************************
 * DB TIER
 * PRIVATE SUBNET CONFIGURATION
 * ALL PRIVATE SUBNET CIDR BLOCK: 10.20.192.0/18
 * 3 availability zones in ap-southeast-2
 **********************************************************/
resource "aws_subnet" "db-private-apse2" {
  // { 0 => [az_name, az_id], ...}
  for_each = { for index,tuple in
                [ for name,id in zipmap(data.aws_availability_zones.all_azs.names,
                                        data.aws_availability_zones.all_azs.zone_ids)
                    : [name, id]
                ] : index => tuple }
    vpc_id = aws_vpc.jt_aws_vpc_main.id
    cidr_block = "10.20.${192 + (16 * each.key)}.0/20"
    availability_zone_id = each.value[1]
    tags = {
      Name = "db-private-${each.value[0]}"
    }
    lifecycle {
      create_before_destroy = true
    }
}
