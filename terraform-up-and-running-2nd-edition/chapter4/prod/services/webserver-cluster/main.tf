#providers are defined in environment, not in source module
provider "aws" { 
    region = "us-east-2" 
} 

#use module from project directory structure
module "webserver_cluster" { 
    source = "../../../modules/services/webserver-cluster"
}

#these are defined as input variables in module
cluster_name = "webservers-prod"
db_remote_state_bucket = {}
db_remote_state_key = {}
instance_type           = "t2.micro"
min_size                = 2
max_size                = 4