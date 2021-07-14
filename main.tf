# Create the VPC Rearc
 resource "aws_vpc" "Rearc" {
   cidr_block = var.rearc_vpc_cidr
   instance_tenancy = "default"
 }

# Create Internet Gateway and attach it to VPC
 resource "aws_internet_gateway" "IGW" {
    vpc_id = aws_vpc.Rearc.id
 }

# Create a Public Subnet1
resource "aws_subnet" "subnet-04e2abe5028713548-RearcSubnetPublic1" {
    vpc_id                  = aws_vpc.Rearc.id
    cidr_block              = "10.0.0.0/24"
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = true

    tags {
        "Name" = "RearcSubnetPublic1"
    }
}

# Create a Public Subnet2
resource "aws_subnet" "subnet-09e7b6acb000e355f-RearcSubnetPublic2" {
    vpc_id                  = aws_vpc.Rearc.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "us-east-1b"
    map_public_ip_on_launch = true

    tags {
        "Name" = "RearcSubnetPublic2"
    }
}

# Route table for Public Subnet
resource "aws_route_table" "RearcRouteTablePublic" {
    vpc_id     = aws_vpc.Rearc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.IGW.id
    }

    tags {
        "Name" = "RearcRouteTablePublic"
    }
}

# Route table Association with Public Subnet1
 resource "aws_route_table_association" "RearcRouteTablePublic" {
    subnet_id = aws_subnet.RearcSubnetPublic1.id
    route_table_id = aws_route_table.RearcRouteTablePublic.id
 }

# Route table Association with Public Subnet2
 resource "aws_route_table_association" "RearcRouteTablePublic" {
    subnet_id = aws_subnet.RearcSubnetPublic2.id
    route_table_id = aws_route_table.RearcRouteTablePublic.id
 }

# Elastic IP
 resource "aws_eip" "RearcEIP" {
   vpc   = true
 }

# Creating the NAT Gateway using subnet_id and allocation_id
resource "aws_nat_gateway" "RearcNATGatewayPublic1" {
    allocation_id = aws_eip.RearcEIP1.id
    subnet_id = aws_subnet.RearcSubnetPublic1.id
}

# Create the EC2 instances
resource "aws_instance" "RearcEC2Public2" {
    ami                         = "ami-0dc2d3e4c0f9ebd18"
    availability_zone           = "us-east-1b"
    ebs_optimized               = false
    instance_type               = "t2.micro"
    monitoring                  = false
    key_name                    = "RearcEC2Key"
    subnet_id                   = "subnet-09e7b6acb000e355f"
    vpc_security_group_ids      = ["sg-0d6ec1a9b23c6d918", "sg-031ab2cd3a39bc85f"]
    associate_public_ip_address = true
    private_ip                  = "10.0.1.182"
    source_dest_check           = true

    root_block_device {
        volume_type           = "gp3"
        volume_size           = 21
        delete_on_termination = true
    }

    tags {
        "Name" = "RearcEC2Public2"
    }
}

resource "aws_instance" "RearcEC2Public1" {
    ami                         = "ami-0dc2d3e4c0f9ebd18"
    availability_zone           = "us-east-1a"
    ebs_optimized               = false
    instance_type               = "t2.micro"
    monitoring                  = false
    key_name                    = "RearcEC2Key"
    subnet_id                   = "subnet-04e2abe5028713548"
    vpc_security_group_ids      = ["sg-0d6ec1a9b23c6d918", "sg-031ab2cd3a39bc85f"]
    associate_public_ip_address = true
    private_ip                  = "10.0.0.202"
    source_dest_check           = true

    root_block_device {
        volume_type           = "gp3"
        volume_size           = 20
        delete_on_termination = true
    }

    tags {
        "Name" = "RearcEC2Public1"
    }
}

# Create Security Groups
resource "aws_security_group" "default" {
    name        = "default"
    description = "default group"
    vpc_id      = ""

    ingress {
        from_port       = 0
        to_port         = 65535
        protocol        = "udp"
        security_groups = []
        self            = true
    }

    ingress {
        from_port       = -1
        to_port         = -1
        protocol        = "icmp"
        security_groups = []
        self            = true
    }

    ingress {
        from_port       = 0
        to_port         = 65535
        protocol        = "tcp"
        security_groups = []
        self            = true
    }
}

resource "aws_security_group" "vpc-07361b04f89252a0c-default" {
    name        = "default"
    description = "default VPC security group"
    vpc_id     = aws_vpc.Rearc.id

    ingress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        security_groups = []
        self            = true
    }


    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

}

resource "aws_security_group" "vpc-07361b04f89252a0c-RearcSSHSG" {
    name        = "RearcSSHSG"
    description = "RearcSSHSG"
    vpc_id     = aws_vpc.Rearc.id

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }


    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

}

resource "aws_security_group" "vpc-07361b04f89252a0c-launch-wizard-1" {
    name        = "launch-wizard-1"
    description = "launch-wizard-1 created 2021-07-14T15:14:42.378-04:00"
    vpc_id     = aws_vpc.Rearc.id

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }


    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

}

resource "aws_security_group" "vpc-07361b04f89252a0c-RearcALBSG" {
    name        = "RearcALBSG"
    description = "RearcALBSG"
    vpc_id     = aws_vpc.Rearc.id

    ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }


    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

}





