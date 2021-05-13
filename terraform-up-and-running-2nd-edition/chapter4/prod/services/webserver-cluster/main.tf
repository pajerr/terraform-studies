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

#Scheduled action to add more load to the cluster during business hours
#ASG group name is from web-server modules output variable
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" { 
    scheduled_action_name = "scale-out-during-business-hours" 
    min_size = 2
    max_size = 4
    desired_capacity = 4
    recurrence = "0 9 * * *"

    autoscaling_group_name = module.webserver_cluster.asg_name
} 

resource "aws_autoscaling_schedule" "scale_in_at_night" { 
    scheduled_action_name = "scale-in-at-night" 
    min_size = 2 
    max_size = 4
    desired_capacity = 2 
    recurrence = "0 17 * * *" 

    autoscaling_group_name = module.webserver_cluster.asg_name

} 
