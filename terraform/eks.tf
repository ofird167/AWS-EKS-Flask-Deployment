# ==========================================
# 1. AWS ECR - Repository for Container Images
# ==========================================
resource "aws_ecr_repository" "AWS-EKS-Flask-Deployment_ecr" {
  name                 = "AWS-EKS-Flask-Deployment-app"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

# ==========================================
# 2. IAM Roles for EKS Cluster
# ==========================================
resource "aws_iam_role" "eks_cluster_role" {
  name = "AWS-EKS-Flask-Deployment-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# ==========================================
# 3. EKS Cluster Definition
# ==========================================
resource "aws_eks_cluster" "AWS-EKS-Flask-Deployment_cluster" {
  name     = "AWS-EKS-Flask-Deployment-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.public_1.id,
      aws_subnet.public_2.id,
      aws_subnet.private_1.id,
      aws_subnet.private_2.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# ==========================================
# 4. IAM Roles for EKS Node Groups
# ==========================================
resource "aws_iam_role" "eks_nodes_role" {
  name = "AWS-EKS-Flask-Deployment-eks-nodes-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes_role.name
}

# ==========================================
# 5. EKS Node Groups (One in Public, One in Private)
# ==========================================

# Node Group 1 - In Public Subnets
resource "aws_eks_node_group" "public_nodes" {
  cluster_name    = aws_eks_cluster.AWS-EKS-Flask-Deployment_cluster.name
  node_group_name = "AWS-EKS-Flask-Deployment-public-node-group"
  node_role_arn   = aws_iam_role.eks_nodes_role.arn
  subnet_ids      = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  instance_types = ["t3.small", "t3.micro"]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
  ]
}

# Node Group 2 - In Private Subnets
resource "aws_eks_node_group" "private_nodes" {
  cluster_name    = aws_eks_cluster.AWS-EKS-Flask-Deployment_cluster.name
  node_group_name = "AWS-EKS-Flask-Deployment-private-node-group"
  node_role_arn   = aws_iam_role.eks_nodes_role.arn
  subnet_ids      = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  instance_types = ["t3.small", "t3.micro"]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
  ]
}