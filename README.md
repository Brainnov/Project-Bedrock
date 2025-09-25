# Project Bedrock: EKS Terraform Deployment

This repository contains Terraform configurations and Kubernetes manifests to provision an AWS EKS cluster and deploy a retail store sample application.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) v1.5+
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- An AWS account with permissions to create EKS, VPC, S3, DynamoDB, and related resources

## Repository Structure

```
terraform/           # Terraform configuration files
kubernetes/          # Kubernetes manifests for the retail store app
workflows/   # GitHub Actions CI/CD workflow
```

## Setup

### 1. Clone the Repository

git clone https://github.com/your-username/project-bedrock.git
cd project-bedrock

### 2. Configure AWS Credentials

Set your AWS credentials as environment variables or configure them in your shell:

export AWS_ACCESS_KEY_ID=your-access-key-id
export AWS_SECRET_ACCESS_KEY=your-secret-access-key
export AWS_DEFAULT_REGION=eu-west-1

### 3. Initialize and Apply Terraform

cd terraform
terraform init
terraform apply

This will provision the VPC, EKS cluster, node group, S3 bucket, DynamoDB table, and other resources.

### 4. Configure kubectl

After Terraform completes, updated my kubeconfig:

aws eks update-kubeconfig --region eu-west-1 --name project-bedrock-eks

### 5. Deploy the Application

Apply the Kubernetes manifests:

kubectl apply -f ../kubernetes/retail-store-app.yaml

### 6. Verify Deployment

Check pods and services:

kubectl get pods -A
kubectl get svc -A

## CI/CD with GitHub Actions

This repository includes a workflow (workflows/terraform-ci-cd.yml) that automates Terraform operations and Kubernetes deployment on push and pull request events.

### Secrets Required

Added the following secrets to your GitHub repository:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Cleaning Up

To destroy all resources:

terraform destroy

Access the retail App:
URL: Retail Store App URL: http://a3288974da9f14e3296c9d9324f1c712-1490008461.eu-west-1.elb.amazonaws.com

## Troubleshooting

- Ensured your AWS credentials are correct and have sufficient permissions.
- Checked the Actions tab in GitHub for CI/CD workflow logs.
- Verified my kubeconfig and cluster status.

Done!
