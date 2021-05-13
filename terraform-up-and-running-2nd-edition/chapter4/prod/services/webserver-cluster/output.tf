#This is "passed through" from source modules output variable
output "alb_dns_name" { 
    value = module.webserver_cluster.alb_dns_name
    description = "The domain name of the load balancer" 
} 
