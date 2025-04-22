###################
# output.tf
###################
#------------------------------------------------------------------------------
# Outputs
#
# This file defines the outputs for the Terraform configuration. Outputs are
# used to display useful information after the infrastructure is provisioned,
# such as resource IDs and DNS names. These outputs can also be referenced by
# other Terraform configurations.
#
# Outputs defined:
# - vpc_id:                The ID of the created VPC.
# - public_subnet_ids:     The IDs of the public subnets within the VPC.
# - private_subnet_ids:    The IDs of the private subnets within the VPC.
# - load_balancer_dns_name:The DNS name of the created Application Load Balancer.
#------------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.alb.dns_name
}
