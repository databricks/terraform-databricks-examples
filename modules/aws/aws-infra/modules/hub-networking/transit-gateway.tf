# Transit Gateway Component
# Creates Transit Gateway with hub-spoke architecture for enterprise networking
# Transit Gateway
resource "aws_ec2_transit_gateway" "main" {
  description                     = "Transit Gateway for ${var.prefix}"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  tags = merge(var.common_tags, {
    Name = local.transit_gateway_name
  })
}
# Hub VPC (when hub-spoke architecture is enabled)
resource "aws_vpc" "hub" {
  cidr_block           = var.hub_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-hub-vpc"
    Type = "Hub"
  })
}
# Hub VPC - Internet Gateway
resource "aws_internet_gateway" "hub" {
  vpc_id = aws_vpc.hub.id
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-hub-igw"
  })
}
# Hub VPC - Public Subnet (single)
resource "aws_subnet" "hub_public" {
  vpc_id                  = aws_vpc.hub.id
  cidr_block              = local.hub_public_subnet_cidr
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-hub-public-subnet"
    Type = "HubPublic"
    AZ   = var.availability_zones[0]
  })
}
# Hub VPC - Private Subnet (single, for Transit Gateway attachment)
resource "aws_subnet" "hub_private" {
  vpc_id            = aws_vpc.hub.id
  cidr_block        = local.hub_private_subnet_cidr
  availability_zone = var.availability_zones[0]
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-hub-private-subnet"
    Type = "HubPrivate"
    AZ   = var.availability_zones[0]
  })
}
# Hub VPC - Firewall Subnet (single)
resource "aws_subnet" "hub_firewall" {
  vpc_id            = aws_vpc.hub.id
  cidr_block        = local.hub_firewall_subnet_cidr
  availability_zone = var.availability_zones[0]
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-hub-firewall-subnet"
    Type = "HubFirewall"
    AZ   = var.availability_zones[0]
  })
}
# Hub VPC - NAT Gateway Elastic IP (single)
resource "aws_eip" "hub_nat" {
  domain = "vpc"
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-hub-nat-eip"
  })
  depends_on = [aws_internet_gateway.hub]
}
# Hub VPC - NAT Gateway (single)
resource "aws_nat_gateway" "hub" {
  allocation_id = aws_eip.hub_nat.id
  subnet_id     = aws_subnet.hub_public.id
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-hub-nat"
    AZ   = var.availability_zones[0]
  })
  depends_on = [aws_internet_gateway.hub]
}
# Hub VPC Route Tables
resource "aws_route_table" "hub_public" {
  vpc_id = aws_vpc.hub.id
  
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-hub-public-rt"
    Type = "HubPublic"
  })
}

resource "aws_route_table" "hub_private" {
  vpc_id = aws_vpc.hub.id
  
  route {
    cidr_block         = var.spoke_vpc_cidr
    transit_gateway_id = aws_ec2_transit_gateway.main.id
  }
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.hub.id
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-hub-private-rt"
    Type = "HubPrivate"
  })
  depends_on = [aws_ec2_transit_gateway_vpc_attachment.hub]
}

resource "aws_route_table" "hub_firewall" {
  vpc_id = aws_vpc.hub.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hub.id
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-hub-firewall-rt"
    Type = "HubFirewall"
  })
}
# Hub VPC Route Table Associations
resource "aws_route_table_association" "hub_public" {
  subnet_id      = aws_subnet.hub_public.id
  route_table_id = aws_route_table.hub_public.id
}
resource "aws_route_table_association" "hub_private" {
  subnet_id      = aws_subnet.hub_private.id
  route_table_id = aws_route_table.hub_private.id
}
resource "aws_route_table_association" "hub_firewall" {
  subnet_id      = aws_subnet.hub_firewall.id
  route_table_id = aws_route_table.hub_firewall.id
}

# Route from Hub Public (NAT location) to Firewall for Internet-bound traffic
resource "aws_route" "hub_public_to_firewall" {
  count = var.enable_firewall ? 1 : 0
  
  route_table_id         = aws_route_table.hub_public.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = one([for k, v in aws_networkfirewall_firewall.main.firewall_status[0].sync_states : v.attachment[0].endpoint_id])
  
  depends_on = [aws_networkfirewall_firewall.main]
}

# Route from Hub Public to IGW when firewall is NOT enabled
resource "aws_route" "hub_public_to_igw" {
  count = var.enable_firewall ? 0 : 1
  
  route_table_id         = aws_route_table.hub_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.hub.id
}

# Transit Gateway VPC Attachment - Spoke (main VPC)
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke" {
  subnet_ids         = var.spoke_private_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id      = var.spoke_vpc_id
  dns_support = "enable"
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-spoke-tgw-attachment"
    Type = "Spoke"
  })
}
# Transit Gateway VPC Attachment - Hub (if hub-spoke is enabled)
resource "aws_ec2_transit_gateway_vpc_attachment" "hub" {
  subnet_ids         = [aws_subnet.hub_private.id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.hub.id
  dns_support        = "enable"
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-hub-tgw-attachment"
    Type = "Hub"
  })
}
# Transit Gateway Route Tables (Custom routing - always required since default propagation is disabled)
resource "aws_ec2_transit_gateway_route_table" "spoke" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-spoke-tgw-rt"
  })
}
resource "aws_ec2_transit_gateway_route_table" "hub" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-hub-tgw-rt"
  })
}
# Route Table Associations
resource "aws_ec2_transit_gateway_route_table_association" "spoke" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}
resource "aws_ec2_transit_gateway_route_table_association" "hub" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hub.id
}
# Transit Gateway Routes
resource "aws_ec2_transit_gateway_route" "spoke_to_hub" {
  destination_cidr_block         = var.hub_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}
resource "aws_ec2_transit_gateway_route" "hub_to_spoke" {
  destination_cidr_block         = var.spoke_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.hub.id
}
# Update main VPC route tables to route to Transit Gateway
resource "aws_route" "private_to_tgw" {
  count                  = length(var.spoke_route_table_ids)
  route_table_id         = var.spoke_route_table_ids[count.index]
  destination_cidr_block = var.hub_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.spoke]
}
# Security Group for Hub VPC
resource "aws_security_group" "hub_default" {
  name_prefix = "${var.prefix}-hub-"
  vpc_id      = aws_vpc.hub.id
  description = "Default security group for hub VPC"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.spoke_vpc_cidr]
    description = "Allow traffic from spoke VPC"
  }
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = [var.spoke_vpc_cidr]
    description = "Allow UDP traffic from spoke VPC"
  }
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-hub-default-sg"
  })
}
