output "server_ips" {
  description = "IP addresses of Nomad servers"
  value       = aws_autoscaling_group.nomad_servers.*.id
}

output "client_ips" {
  description = "IP addresses of Nomad clients"
  value       = aws_autoscaling_group.nomad_clients.*.id
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.nomad_servers.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.nomad_servers.zone_id
}

output "server_target_group_arn" {
  description = "ARN of the server target group"
  value       = aws_lb_target_group.nomad_servers.arn
}

output "client_target_group_arn" {
  description = "ARN of the client target group"
  value       = aws_lb_target_group.nomad_clients.arn
}

output "server_autoscaling_group_name" {
  description = "Name of the server auto scaling group"
  value       = aws_autoscaling_group.nomad_servers.name
}

output "client_autoscaling_group_name" {
  description = "Name of the client auto scaling group"
  value       = aws_autoscaling_group.nomad_clients.name
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.nomad.name
}