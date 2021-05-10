output "alb_dns_name" {
  value = aws_lb.example.dns_name
  description = "The domain name of the load balancer" 
}

#output "rds_db_address" {
#  value = terraform_remote_state.db.outputs.address
#  description = "IP of mysql rds instance"
#}
