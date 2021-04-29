provider "aws" {
    region = "us-east-2"
}

resource "aws_launch_configuration" "example" {
    image_id           = "ami-0c55b159cbfafe1f0"
    instance_type      = "t2.micro"
    security_groups    = [aws_security_group.instance.id]

#To use a reference inside of a string literal, you need to use a new type of expression called an interpolation, which has the following syntax:

    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p "${var.server_port}" &
                EOF

    #ASG uses reference to fill in launch configuration name
    #Launch configs are immutable so if you change parameter to launch config 
    #Terraform will try to replace it, old resources are deleted first, before creating new one
    #ASG has reference to old resource and wont be able to delete it
    #We need lifecycle to specify create new instance before deletion
    lifecycle { 
    create_before_destroy = true 
    }  
}


#Data source to look up default VPC in AWS
data "aws_vpc" "default" { 
  default = true 
}

#2nd DS to use in combination with the above to look up subnets in VPC
data "aws_subnet_ids" "default" { 
  vpc_id = data.aws_vpc.default.id
} 

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  #use data source to pull subnet ID and to tell ASG to deploy resources to that subnet specified by ID
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids

  #target_group_arns = [aws_lb_target_group.asg.arn]
  #health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

### Load balancer resource definition
resource "aws_lb" "example" {

  name               = "terraform-asg-example"
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

#To allow traffic to LB we need to create SG where we allow traffic
resource "aws_security_group" "alb" {

  name = var.alb_security_group_name

  # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}