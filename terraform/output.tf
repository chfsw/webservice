output "public_ipA" {
  value = aws_instance.my_instanceA.public_ip
}
output "public_ipB" {
  value = aws_instance.my_instanceB.public_ip
}
#Output the public DNS name of the load balancer
output "public_dns" {
    value = aws_lb.my_lb.dns_name
}