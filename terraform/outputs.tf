output "cluster_name" {
  description = "The name of the EKS Cluster"
  value       = aws_eks_cluster.interview1_cluster.name
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API"
  value       = aws_eks_cluster.interview1_cluster.endpoint
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.interview1_ecr.repository_url
}

output "iam_role_arn" {
  description = "The IAM Role ARN for the EKS Cluster"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.interview1_vpc.id
}