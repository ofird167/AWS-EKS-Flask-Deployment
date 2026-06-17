resource "null_resource" "update_kubeconfig" {
  # הפקודה תרוץ רק אחרי שהקלאסטר והנודים הציבוריים סיימו לעלות לחלוטין
  depends_on = [
    aws_eks_cluster.AWS-EKS-Flask-Deployment_cluster,
    aws_eks_node_group.public_nodes
  ]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region us-east-1 --name ${aws_eks_cluster.AWS-EKS-Flask-Deployment_cluster.name}"
  }
}
