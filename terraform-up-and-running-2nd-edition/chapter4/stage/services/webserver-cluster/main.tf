#providers are defined in environment, not in source module
provider "aws" { 
    region = "us-east-2" 
} 

#use module from project directory structure
module "webserver_cluster" { 
    source = "../../../modules/services/webserver-cluster"
}

