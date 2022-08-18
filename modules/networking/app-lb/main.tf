terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

#Main/Primary VPC
resource "aws_vpc" "prod-vpc" {
  cidr_block = var.vpc_cidr
 tags = { 
          Project = "Assessment" 
          Name = "Web Server VPC"
        }
}

#Primary Public Subnet
resource "aws_subnet" "public_subnet1" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = var.public_subnet1_cidr_block
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

#Secondary Public Subnet
resource "aws_subnet" "public_subnet2" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = var.public_subnet2_cidr_block
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

#Primary Private Subnet
resource "aws_subnet" "private_subnet1" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = var.private_subnet1_cidr_block
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-1"
  }
}

#Secondary Private Subnet
resource "aws_subnet" "private_subnet2" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = var.private_subnet2_cidr_block
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-subnet-2"
  }
}

#Internet gateway
 resource "aws_internet_gateway" "igw" {
    vpc_id =  aws_vpc.prod-vpc.id
 }

#Create Internet route for public subnets
resource "aws_route_table" "public_subnet1_route" {
  vpc_id = aws_vpc.prod-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
   }
    tags = {
    Project = "Assessment"
    Name = "public subnet Internet route table" 
 }
}

#Create route table association for both public subnets
resource "aws_route_table_association" "internet_for_pub_sub1" {
  route_table_id = aws_route_table.public_subnet1_route.id
  subnet_id      = aws_subnet.public_subnet1.id
}
resource "aws_route_table_association" "internet_for_pub_sub2" {
  route_table_id = aws_route_table.public_subnet1_route.id
  subnet_id      = aws_subnet.public_subnet2.id
}

#Create Elastic IPs and NAT Gateways for ingress/egress on both public subnets
resource "aws_eip" "eip_natgw1" {  
     count = "1"
} 

resource "aws_eip" "eip_natgw2" { 
     count = "1"
}

resource "aws_nat_gateway" "natgateway_1" {  
     count         = "1"  
     allocation_id = aws_eip.eip_natgw1[count.index].id  
     subnet_id     = aws_subnet.public_subnet1.id
} 

resource "aws_nat_gateway" "natgateway_2" {               
     count    = "1"  
     allocation_id = aws_eip.eip_natgw2[count.index].id 
     subnet_id     = aws_subnet.public_subnet2.id
}

#Create private routing table for private subnet 1
resource "aws_route_table" "private_subnet1_route" {
  count  = "1"
  vpc_id = aws_vpc.prod-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway_1[count.index].id
  }
  tags = {
    Project = "Assessment"
    Name = "private subnet1 routing table" 
 }
}
#Create route table association between private subnet 1 & NAT Gateway 1
resource "aws_route_table_association" "pri_sub1_to_natgw1" {
  count          = "1"
  route_table_id = aws_route_table.private_subnet1_route[count.index].id
  subnet_id      = aws_subnet.private_subnet1.id
}

#Create private route table for private subnet 2
resource "aws_route_table" "private_subnet2_route" {
  count  = "1"
  vpc_id = aws_vpc.prod-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway_2[count.index].id
  }
  tags = {
    Project = "Assessment"
    Name = "private subnet2 routing table"
  }
}
#Create route table association between private subnet 2 & NAT Gateway 2
resource "aws_route_table_association" "pri_sub2_to_natgw1" {
  count          = "1"
  route_table_id = aws_route_table.private_subnet1_route[count.index].id
  subnet_id      = aws_subnet.private_subnet2.id
}

#Create security group for load balancer
resource "aws_security_group" "elb_securitygroup" {
  name        = var.securitygroup_name
  description = var.securitygroup_description
  vpc_id      = aws_vpc.prod-vpc.id
ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }
egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
 
 tags = {
    Name = var.securitygroup_tagname
    Project = "Assessment" 
  } 
}

#Create security group for webserver
resource "aws_security_group" "webserver_securitygroup" {
  name        = var.webserver_securitygroup_name
  description = var.webserver_securitygroup_description
  vpc_id      = aws_vpc.prod-vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
   }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = var.webserver_securitygroup_tagname 
    Project = "Assessment"
  }
}

#Create target group
resource "aws_lb_target_group" "target_group" {
  name     = "tg-example"
  depends_on = [aws_vpc.prod-vpc]
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.prod-vpc.id}"
  health_check {
    interval            = 70
    path                = "/index.html"
    port                = 80
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 60 
    protocol            = "HTTP"
    matcher             = "200,202"
  }
}

#Create Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "alb-example"
  internal           = false
  load_balancer_type = "application"
  security_groups  = [aws_security_group.elb_securitygroup.id]
  subnets          = [aws_subnet.public_subnet1.id,aws_subnet.public_subnet2.id]       
  tags = {
        name  = "app_lb"
        Project = "Assessment"
       }
}
#Create Listener for ALB
resource "aws_lb_listener" "public_access" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}