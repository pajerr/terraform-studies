#providers are defined in environment, not in source module
provider "aws" { 
    region = "us-east-2" 
} 

#use module from project directory structure
module "webserver_cluster" { 
    source                  = "../../../modules/services/webserver-cluster"
    cluster_name            = var.cluster_name
    db_remote_state_bucket  = var.db_remote_state_bucket
    db_remote_state_key     = var.db_remote_state_key
    instance_type           = var.instance_type
    min_size                = var.min_size
    max_size                = var.max_size
}

