#Server port variable used in user data and EC2 security group
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "alb_security_group_name" {
  default = "terraform-example-alb"
}

variable "alb_name" {
  default = "terraform-alb-tg"
}

variable "s3_bucket_name" {}