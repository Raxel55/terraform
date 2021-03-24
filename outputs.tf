output "aws_ecr_repository_url" {
  value = data.aws_ecr_repository.kanda.repository_url
}

output "aws_db_instance_address" {
  value = data.aws_db_instance.kanda.address
}

output "aws_ec2_ssh_private_key" {
  value = tls_private_key.kanda-ssh[0].private_key_pem
  sensitive = true
}

output "load_balancer_dns_name" {
  value = data.aws_lb.kanda.dns_name
}
