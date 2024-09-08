terraform {
  backend "s3" {
    bucket         = "mystatefilestorage"
    key            = "terraform/state.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

resource "aws_vpc" "main" {
	cidr_block = var.vpc
	tags = {
		Name = "My VPC"
	}
}

resource "aws_subnet" "pub1" {
	vpc_id = aws_vpc.main.id
	cidr_block = var.sub_pub1
	availability_zone = "us-east-1a"
	map_public_ip_on_launch = true
	tags = {
		Name = "My public subnet1"
	}
}

resource "aws_subnet" "pub2" {
        vpc_id = aws_vpc.main.id
        cidr_block = var.sub_pub2
        availability_zone = "us-east-1b"
        map_public_ip_on_launch = true
        tags = {
                Name = "My public subnet2"
        }
}

resource "aws_subnet" "priv" {
        vpc_id = aws_vpc.main.id
        cidr_block = var.sub_priv
        availability_zone = "us-east-1a"
        map_public_ip_on_launch = false
        tags = {
                Name = "My private subnet1"
        }
}

resource "aws_internet_gateway" "myigw" {
	vpc_id = aws_vpc.main.id
	tags = {
		Name = "My internet Gateway"
	}
}

resource "aws_route_table" "mypub_RT1" {
	vpc_id = aws_vpc.main.id
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.myigw.id
	}
	tags = {
		Name = "My pub1 RT"
	}
}

resource "aws_route_table" "mypub_RT2" {
        vpc_id = aws_vpc.main.id
        route {
                cidr_block = "0.0.0.0/0"
                gateway_id = aws_internet_gateway.myigw.id
        }
        tags = {
                Name = "My pub2 RT"
	}
}

resource "aws_route_table" "mypriv_RT" {
        vpc_id = aws_vpc.main.id
        route {
                cidr_block = "0.0.0.0/0"
		nat_gateway_id = aws_nat_gateway.nat_gw.id
        }
        tags = {
                Name = "My priv RT"
	}
}

resource "aws_route_table_association" "pub_rta_1" {
	subnet_id = aws_subnet.pub1.id
	route_table_id = aws_route_table.mypub_RT1.id
}

resource "aws_route_table_association" "pub_rta_2" {
        subnet_id = aws_subnet.pub2.id
        route_table_id = aws_route_table.mypub_RT2.id
}

resource "aws_route_table_association" "priv_rta" {
        subnet_id = aws_subnet.priv.id
        route_table_id = aws_route_table.mypriv_RT.id
}

resource "aws_security_group" "pub_sg" {
	name = "Pulic-Security-Group"
	vpc_id = aws_vpc.main.id
	ingress {
		description = "HTTP port"
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	ingress {
                description = "HTTPS port"
                from_port = 443
                to_port = 443
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
	ingress {
                description = "SSH port"
                from_port = 22
                to_port = 22
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
	ingress {
                description = "RDP"
                from_port = 3389
                to_port = 3389
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	tags = {
		Name = "Public Security Group"
	}
}

resource "aws_security_group" "priv_sg" {
	name = "Private Security Group"
	vpc_id = aws_vpc.main.id
	ingress {
		description = "All portss from public subnet"
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = [var.sub_pub1, var.sub_pub2]
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	tags = {
		Name = "Private Security Group"
	}
}

resource "aws_instance" "pub1" {
	ami = var.ami_id
	instance_type = var.instance_type
	key_name = "MyTerraform-Key"
	vpc_security_group_ids = [aws_security_group.pub_sg.id]
	subnet_id = aws_subnet.pub1.id
	availability_zone = "us-east-1a"
	user_data = file("${path.module}/user_data.sh")
	tags = {
		Name = "Pub1 instance"
	}
}

resource "aws_instance" "pub2" {
        ami = var.ami_id
        instance_type = var.instance_type
        key_name = "MyTerraform-Key"
        vpc_security_group_ids = [aws_security_group.pub_sg.id]
        subnet_id = aws_subnet.pub2.id
        availability_zone = "us-east-1b"
        user_data = file("${path.module}/user_data.sh")
        tags = {
                Name = "Pub2 instance"
        }
}

resource "aws_instance" "priv" {
        ami = var.ami_id
        instance_type = var.instance_type
        key_name = "MyTerraform-Key"
        vpc_security_group_ids = [aws_security_group.priv_sg.id]
        subnet_id = aws_subnet.priv.id
        availability_zone = "us-east-1a"
        tags = {
                Name = "Priv instance"
        }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_ip" {
	domain = "vpc"  # This is required for NAT Gateway usage in a VPC
}

# NAT Gateway in public subnet
resource "aws_nat_gateway" "nat_gw" {
	allocation_id = aws_eip.nat_ip.id
	subnet_id = aws_subnet.pub1.id
	tags = {
		Name = "nat-gateway"
  	}
}

resource "aws_lb" "mylb" {
	name = "MyLoadBalancer"
	internal = false
	load_balancer_type = "application"
	security_groups = [aws_security_group.pub_sg.id]
	subnets = [aws_subnet.pub1.id, aws_subnet.pub2.id]
	tags = {
		Name = "My_Application_Load_Balancer"
	}
}

resource "aws_lb_target_group" "MyTG" {
	name = "MyTG"
	port = 80
	protocol = "HTTP"
	vpc_id = aws_vpc.main.id
	health_check {
    		path = "/"
		port = "traffic-port"
	}
}

resource "aws_lb_target_group_attachment" "MyTG_attach1" {
	target_group_arn = aws_lb_target_group.MyTG.arn 
	target_id = aws_instance.pub1.id 
	port = 80
}

resource "aws_lb_target_group_attachment" "MyTG_attach2" {
	target_group_arn = aws_lb_target_group.MyTG.arn 
	target_id = aws_instance.pub2.id 
	port = 80
}

resource "aws_lb_listener" "MyLb_listner" {
	load_balancer_arn = aws_lb.mylb.arn
	port = 80
	protocol = "HTTP" 
	default_action {
    		target_group_arn = aws_lb_target_group.MyTG.arn
    		type = "forward"
 	}
}

output "loadbalancerdns" {
	value = aws_lb.mylb.dns_name
}






 
