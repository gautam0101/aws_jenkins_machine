provider "aws" {
  region     = var.aws-region
  access_key = var.access_key
  secret_key = var.secret_key
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create the first subnet
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"  # Replace with your desired availability zone
}

# Create the second subnet
resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1b"  # Replace with your desired availability zone
}

# Create a security group
resource "aws_security_group" "instance_sg" {
  name_prefix = "instance-sg-"
vpc_id      = aws_vpc.my_vpc.id
  description = "create the Security Group"

   ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2000
    to_port     = 2000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2400
    to_port     = 2400
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Add more ingress and egress rules if needed
}

# Launch an EC2 instance
resource "aws_instance" "instance" {
ami = "ami-077053fb4029de92f"
instance_type = "t4g.micro"
key_name = "non-prod"
  subnet_id         = aws_subnet.subnet1.id  # Use the first subnet
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  tags = {
    Name = "ExampleInstance"
  }
}


resource "aws_launch_template" "aws_temp" {
  name          = "my-launch-template"
  image_id      = "ami-0f5ee92e2d63afc18"  
  instance_type = "t2.small" 
 
}

resource "aws_autoscaling_group" "aws_autoscaling" {
  name                      = "my-autoscaling-group"
  min_size                  = 1  
  max_size                  = 4  
  desired_capacity          = 1  
  health_check_type         = "EC2"
  vpc_zone_identifier       = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]  
  launch_template {
    id = aws_launch_template.aws_temp.id
    version = "$Latest"  
  }
}
resource "aws_internet_gateway" "aws_gateway" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_lb" "aws_load" {
  name               = "my-load-balancer"
  load_balancer_type = "application"
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  security_groups = [aws_security_group.instance_sg.id]
}

resource "aws_lb_target_group" "aws_target" {
  vpc_id = aws_vpc.my_vpc.id
  name        = "my-target-group"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
}

resource "aws_lb_listener" "aws_listner" {
  load_balancer_arn = aws_lb.aws_load.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws_target.arn
  }
}
