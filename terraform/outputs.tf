output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "developer_iam_user" {
  description = "Developer IAM user name"
  value       = aws_iam_user.developer.name
}

output "developer_access_key_id" {
  description = "Developer access key ID"
  value       = aws_iam_access_key.developer.id
  sensitive   = true
}

output "developer_secret_access_key" {
  description = "Developer secret access key"
  value       = aws_iam_access_key.developer.secret
  sensitive   = true
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "node_group_status" {
  description = "EKS node group status"
  value       = aws_eks_node_group.main.status
}

output "ui_service_external_ip" {
  description = "External IP/LB for UI service"
  value       = "Run: kubectl get svc ui -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "application_access_instructions" {
  description = "Instructions to access the application"
  value       = <<EOT
To access the Retail Store application:

1. Get the UI service external URL:
   kubectl get svc ui -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

2. Open the URL in your browser

3. Developer access credentials are available in the outputs above.

The application includes:
- Catalog service (MySQL)
- Cart service (DynamoDB)
- Orders service (PostgreSQL + RabbitMQ)
- Checkout service (Redis)
- UI service (LoadBalancer)

All dependencies are running in-cluster as required.
EOT
}