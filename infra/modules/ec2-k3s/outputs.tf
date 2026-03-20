output "security_group_id" {
  value = aws_security_group.ec2.id
}

output "public_ip" {
  value = aws_eip.k3s.public_ip
}

output "instance_id" {
  value = aws_instance.k3s.id
}