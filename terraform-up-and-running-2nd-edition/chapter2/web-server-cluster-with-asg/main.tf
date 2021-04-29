provider "aws" {
    region = "us-east-2"
}

resource "aws_launch_configuration" "example" {
  image_id        = "ami-0c55b159cbfafe1f0"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  # Required when using a launch configuration with an auto scaling group.
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  #use data source to pull subnet ID and to tell ASG to deploy resources to that subnet specified by ID
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids

  #Attach EC2 instances created by ASG to ALBs target group
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
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

#Security group attached to EC2 instances
resource "aws_security_group" "instance" {
    name = "terraform-example-instance"
    ingress {
        from_port   = var.server_port
        to_port     = var.server_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
  }
}

#Server port variable used in user data and EC2 security group
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

#LB resource itself
resource "aws_lb" "example" {

  #name               = var.alb_name
  name               = "terraform-asg-example" 

  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default.ids

  #Tell LB to use Security group "alb" defined in Security group resource
  security_groups    = [aws_security_group.alb.id]
}

#LB listener rules that specify where to forward traffic
#Rule sends requests to any path to target group attached to ASG
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

#AWS Listener config
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

variable "alb_security_group_name" {
  default = "terraform-example-alb"
}

#LB Security group resource to control inbound and outbound traffic
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

variable "alb_name" {
  default = "terraform-alb-tg"
}

#Target group for LB to specify where to forward incoming traffic
resource "aws_lb_target_group" "asg" {

  name = var.alb_name

  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

output "alb_dns_name" { 
  value = aws_lb.example.dns_name
  description = "The domain name of the load balancer" 
}