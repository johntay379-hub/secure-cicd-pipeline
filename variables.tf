# ============================================================
#  variables.tf
#  All configurable values in one place
#  Change these without touching the main code
# ============================================================

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name used to tag and name all resources"
  type        = string
  default     = "cicd-pipeline"
}

variable "vpc_cidr" {
  description = "IP range for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "IP range for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t2.micro"
}