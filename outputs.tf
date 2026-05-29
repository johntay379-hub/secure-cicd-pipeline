# ============================================================
#  outputs.tf
#  Values that print after terraform apply completes
#  These tell you what was created and how to access it
# ============================================================

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "ec2_instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "The public IP address of the web server"
  value       = aws_eip.web.public_ip
}

output "website_url" {
  description = "Visit this URL in your browser to see the web server"
  value       = "http://${aws_eip.web.public_ip}"
}