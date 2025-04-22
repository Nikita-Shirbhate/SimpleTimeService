# Specifies the AWS region where resources will be deployed.
# Type: string
# Default: "us-east-1"

variable "aws_region" {
  description = "The AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}
