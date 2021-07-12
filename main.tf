# Create the VPC Rearc
 resource "aws_vpc" "Rearc" {
   cidr_block = var.rearc_vpc_cidr
   instance_tenancy = "default"
 }

# Create Internet Gateway and attach it to VPC
 resource "aws_internet_gateway" "IGW" {
    vpc_id = aws_vpc.Rearc.id
 }

# Create a Public Subnet
 resource "aws_subnet" "publicsubnets" {
   vpc_id = aws_vpc.Rearc.id
   cidr_block = "${var.public_subnets}"
 }

# Create a Private Subnet
 resource "aws_subnet" "privatesubnets" {
   vpc_id = aws_vpc.Rearc.id
   cidr_block = "${var.private_subnets}"
 }

# Route table for Public Subnet
 resource "aws_route_table" "PublicRT" {
  vpc_id =  aws_vpc.Rearc.id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.IGW.id
    }
 }

# Route table for Private Subnet
 resource "aws_route_table" "PrivateRT" {
  vpc_id = aws_vpc.Rearc.id
    route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.NATgw.id
    }
 }

# Route table Association with Public Subnet
 resource "aws_route_table_association" "PublicRTassociation" {
    subnet_id = aws_subnet.publicsubnets.id
    route_table_id = aws_route_table.PublicRT.id
 }

# Route table Association with Private Subnet
 resource "aws_route_table_association" "PrivateRTassociation" {
    subnet_id = aws_subnet.privatesubnets.id
    route_table_id = aws_route_table.PrivateRT.id
 }

# Elastic IP
 resource "aws_eip" "RearcEIP" {
   vpc   = true
 }

# Creating the NAT Gateway using subnet_id and allocation_id
 resource "aws_nat_gateway" "NATgw" {
   allocation_id = aws_eip.RearcEIP.id
   subnet_id = aws_subnet.publicsubnets.id
 }
