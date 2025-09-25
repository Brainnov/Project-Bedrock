# AWS Auth ConfigMap to allow worker nodes to join the cluster
resource "kubernetes_config_map" "aws_auth" {
  depends_on = [aws_eks_cluster.main]

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = aws_iam_role.eks_node_group.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes",
        ]
      }
    ])
  }
}

# Apply the retail store app manifest using null_resource
resource "null_resource" "apply_retail_store_app" {
  depends_on = [
    aws_eks_node_group.main,
    kubernetes_config_map.aws_auth
  ]

  triggers = {
    manifest_sha     = filesha256("${path.module}/../kubernetes/retail-store-app.yaml")
    cluster_endpoint = aws_eks_cluster.main.endpoint
  }

  provisioner "local-exec" {
    command = <<EOT
      # Wait for nodes to be ready
      echo "Waiting for EKS nodes to be ready..."
      timeout 600 bash -c 'until kubectl get nodes --no-headers 2>/dev/null | grep -q "Ready"; do sleep 10; echo "Waiting..."; done'
      
      # Apply the retail store app
      echo "Applying retail store application..."
      kubectl apply -f ../kubernetes/retail-store-app.yaml --validate=false
      
      # Wait for all pods to be running
      echo "Waiting for all pods to be ready..."
      timeout 600 bash -c 'until kubectl get pods --all-namespaces --no-headers 2>/dev/null | grep -v Running | grep -v Completed | wc -l | grep -q "^0$"; do sleep 10; echo "Waiting for pods..."; done'
      
      echo "Retail store application deployed successfully!"
      
      # Display services
      echo "Services:"
      kubectl get svc -A
    EOT

    environment = {
      KUBECONFIG = "/tmp/kubeconfig-${var.cluster_name}"
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      # Clean up the application when destroying
      kubectl delete -f ../kubernetes/retail-store-app.yaml --ignore-not-found=true
    EOT
  }
}

# Cluster role for developer read-only access
resource "kubernetes_cluster_role" "developer_readonly" {
  metadata {
    name = "developer-readonly"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "configmaps", "secrets", "namespaces", "events", "endpoints", "persistentvolumeclaims"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets", "statefulsets", "daemonsets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list", "watch"]
  }
}

# Role binding for developer user
resource "kubernetes_cluster_role_binding" "developer_readonly" {
  metadata {
    name = "developer-readonly-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.developer_readonly.metadata[0].name
  }

  subject {
    kind      = "User"
    name      = "developer"
    api_group = "rbac.authorization.k8s.io"
  }
}

# Service account for the retail store app (if needed for additional permissions)
resource "kubernetes_service_account" "retail_store_admin" {
  metadata {
    name      = "retail-store-admin"
    namespace = "default"
  }

  automount_service_account_token = true
}