#Server port variable used in user data and EC2 security group
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "alb_security_group_name" {
  default = "terraform-example-alb-sg"
}

variable "alb_name" {
  default = "terraform-example-alb"
}

#variable "s3_bucket_name" {}

#variable "PATH_TO_PRIVATE_KEY" {
#  default = "my-test-key"
#}

#variable "PATH_TO_PUBLIC_KEY" {
#  default = "my-test-key.pub"
#}

#Input parameters
variable "cluster_name" { 
  description = "The name to use for all the cluster resources" 
  type = string
}

variable "db_remote_state_bucket" { 
  description = "The name of the S3 bucket for the database's remote state" 
  type = string
} 

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3" 
  type = string 
}

#This are used to configure lighter environment for staging and normal for prod for example
variable "instance_type" { 
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type = string
}

variable "min_size" { 
  description = "The minimum number of EC2 Instances in the ASG" 
  type = number 
} 

variable "max_size" { 
  description = "The maximum number of EC2 Instances in the ASG" 
  type = number
}