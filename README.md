#  🚀Terraform AWS Infrastructure Deployment 

This project deploys a complete AWS infrastructure including VPC, EC2 instance, Security Groups, EKS cluster, and ECR repository using Terraform. The deployment uses modules for reusability and stores state securely in S3 with DynamoDB for locking.
 Terraform AWS Infrastructure – Detailed Documentation

📐 **Architecture Diagram:** 

Here is the main architecture of the project:
![Architecture Diagram](https://drive.google.com/uc?export=view&id=1HKmOLXlfygEcMnTrHGCBOmLEUaT1gc0H)

# 📌 Table of Contents
 
   🧠 Project Overview

 1. 🧰 Prerequisites

2. 🗂️ Project Structure

3. 🧩 Modules Overview

    - 🌐 VPC

    - 🖥️ EC2

    - 🔐 Security Group

    - ☸️ EKS

    - 📦 ECR

4- ⚙️ Variables

5- 💾 Terraform Backend

6- ▶️ How to Run

7- 🧪 Example Deployment Flow

8- 🔁 Ansible Automation 

# 🧠 Project Overview
 

   -  🔁 Install ArgoCD via Helm: The playbook adds the ArgoCD Helm repository, installs ArgoCD in the argocd namespace, and patches the argocd-server service to LoadBalancer.

   - 🔐 Configure ArgoCD repository secrets securely:
        All sensitive data (GitHub tokens, etc.) are stored in HashiCorp Vault.
        Ansible fetches the GitHub token from Vault at runtime.
        A Kubernetes secret is created in ArgoCD with the repository credentials.

   - 🗂️ Create ArgoCD ApplicationSet:

        The Application.yaml defines an ApplicationSet that automatically discovers and syncs all directories in the Git repository (apps/*).

        Sync policy is automated with prune and selfHeal enabled.


# 🧰 Prerequisites

  Before running this project, make sure you have:

1- Terraform v1.5+

2- AWS CLI configured (aws configure)

3- AWS account with IAM permissions

4- Existing:

   - 🪣 S3 bucket (for state)

  - 🔒 DynamoDB table (for state locking)

5- EC2 Key Pair (for SSH access)

# 🗂️ Project Structure
 ```text
.
├── main.tf              # Calls all modules
├── variables.tf         # Variable definitions
├── terraform.tf         # Backend configuration
├── terraform.tfvars     # Actual variable values
└── modules/
    ├── vpc/
    ├── ec2/
    ├── security_group/
    ├── eks/
    └── ecr/
 └── ansible
     ├── argocd/
      │       ├── tasks/main.yml
      │       └── files/
      │           ├── secrets.yaml
      │           └── Application.yaml

```
# 🧩 Modules Overview
1- **🌐 VPC Module**

📍 Path: modules/vpc
  
  Creates:
   - VPC
   - Public subnet
   - Private subnets
   - Internet Gateway
   - NAT Gateway
  
  Inputs:

    Variable                 	Description
    cidr_vpc	                VPC CIDR block
    cidr_private	            List of private subnet CIDRs
    public_subnet_cidr      	Public subnet CIDR
    name_private	            Names of private subnets
    name_public	             Name of public subnet
    vpc_name	                VPC name
    igw	                     Internet Gateway name

 Outputs:

   - vpc_id
   -  private_subnet_id
   -   public_subnet_id
     
2- **🖥️ EC2 Module**

📍 Path: modules/ec2
  
  Creates:
   - EC2 instance in public subnet

  Inputs:

    Variable	                  Description
    subnet_id	                  Subnet ID
    public_ip_or_not	           Assign public IP
    ami                        	AMI ID
    volume_size	                Root volume size (GB)
    key_name	                   SSH key name
    instance_type	              EC2 instance type
    security_group_ids	         Security group IDs
    ec2_names	                  Instance names


3- **🔐 Security Group Module**

📍 Path: modules/security_group
   
  Creates:
   - Security group attached to the VPC
   
  Inputs:

    Variable	        Description
    vpc_id            	VPC ID
    vpc_cidr	          CIDR for inbound rules
  
  Outputs:
   
   - 🔑 sg_id
     
4-   **☸️ EKS Module**

 📍 Path: modules/eks
   
   Creates:
   - EKS Cluster
    
   - Managed Node Group
   
   Inputs:

    Variable                       	Description
    eks_subnets_ids	             Control plane subnets
    eks_nodes_subnets_ids	       Node group subnets
    security_group_ids	          Security groups
    enable_private_access	       Private API access
    enable_public_access	        Public API access
    nodes_ec2_type	Node          instance types
    node_group_name	             Node group name
    min_nodes	                   Min nodes
    max_nodes	                   Max nodes
    desired_nodes	               Desired nodes
    k8s_version	                 Kubernetes version
    cluster_name                 Cluster name

5-  **📦 ECR Module**

📍 Path: modules/ecr
  
  Creates:
   - Amazon ECR repository
   
   Inputs:
    
    Variable	             Description
    ecr_name	           Repository name
    
   Outputs:
   - 📎 Repository URI


# ⚙️ Variables
   ```sh
   variable "region" {}
   variable "vpc_cidr" {}
   variable "private_subnets_cidr" {}
   variable "public_subnets_cidr" {}
   variable "private_subnets_names" {}
   variable "public_subnets_names" {}
   variable "vpc_name" {}
   variable "igw_name" {}
   ```
 **📄 terraform.tfvars Example**
   ```sh
   region = "eu-north-1"
   
   vpc_cidr = "10.44.0.0/16"
   
   private_subnets_cidr = [
     "10.44.1.0/24",
     "10.44.2.0/24",
     "10.44.4.0/24"
   ]
   
   public_subnets_cidr = "10.44.3.0/24"
   
   private_subnets_names = [
     "private-subnet-a",
     "private-subnet-b",
     "private-subnet-c"
   ]
   
   public_subnets_names = "public-subnet"
   
   vpc_name = "eks-vpc"
   igw_name = "igw"

   ```

# 💾 Terraform Backend
  Remote backend configuration:
  ```hcl
   terraform {
     backend "s3" {
       bucket         = "terr-statefile-bucket2"
       key            = "state/file.tfstate"
       region         = "eu-north-1"
       dynamodb_table = "lock_table"
       encrypt        = true
     }
   }
  ```
3 ▶️ How to Run
```sh
terraform init
terraform plan
terraform apply
``` 

# 🧹 To destroy:
```sh
terraform destroy
```

# 🧪 Example Deployment Flow
   1️⃣ Create VPC
   
   2️⃣ Create subnets & IGW
   
   3️⃣ Create Security Group
   
   4️⃣ Launch EC2 in public subnet
   
   5️⃣ Deploy EKS cluster in private subnets
   
   6️⃣ Create ECR repository

 

# 🔁 Ansible Automation 

1- for ArgoCD Deployment

1️⃣ Project Overview

This project automates the deployment and configuration of ArgoCD on a Kubernetes cluster using:

 - Ansible

 - Helm

 - Kubernetes

 - ApplicationSet (GitOps)

 - Ansible Vault (Secure GitHub authentication)

The automation performs:

 - Helm installation

 - ArgoCD deployment

 - Service exposure

 - Admin credential retrieval

 - Secure GitHub repository integration

 - ApplicationSet creation for GitOps workflow

2️⃣ Architecture Overview

Deployment Flow:

         Ansible
            ↓
         Helm
            ↓
         Kubernetes Cluster
            ↓
         ArgoCD
            ↓
         GitHub Repository
            ↓
         ApplicationSet → Auto Deployment

3️⃣ ArgoCD Deployment via Helm

Helm repository is added:

      kubernetes.core.helm_repository:
        name: argo
        repo_url: https://argoproj.github.io/argo-helm


Then ArgoCD is installed:

      kubernetes.core.helm:
        name: argocd
        chart_ref: argo/argo-cd
        release_namespace: argocd
        create_namespace: true

4️⃣ Exposing ArgoCD Service

The ArgoCD service is patched to LoadBalancer:

      kubectl patch svc argocd-server -n argocd \
      -p '{"spec": {"type": "LoadBalancer"}}'


Then the External IP is retrieved:

      kubectl get svc argocd-server -n argocd



5️⃣ Retrieving ArgoCD Admin Credentials

The initial admin password is extracted from Kubernetes Secret:

      kubectl -n argocd get secret argocd-initial-admin-secret \
      -o jsonpath="{.data.password}" | base64 --decode


6️⃣ Secure GitHub Authentication using Ansible Vault

To prevent exposing GitHub Personal Access Token (PAT), Ansible Vault is used.

Encrypted using:

      ansible-vault create vault.yml

Vault File (vault.yml)

      github_token: ghp_xxxxxxxxxxxxx



7️⃣ Git Repository Secret for ArgoCD

A Kubernetes Secret is created dynamically:
      
      apiVersion: v1
      kind: Secret
      metadata:
        name: app-repo
        namespace: argocd
        labels:
          argocd.argoproj.io/secret-type: repository
      type: Opaque
      stringData:
        url: https://github.com/tetris-app1/Application_Repo.git
        username: linamohamed93
        password: "{{ github_token }}"


This allows ArgoCD to securely authenticate if  GitHub repository is a private.


8️⃣ ApplicationSet Configuration (GitOps Automation)

The ApplicationSet automatically generates applications from the Git repository:
      
      apiVersion: argoproj.io/v1alpha1
      kind: ApplicationSet

Features:

   1- Git generator

   2- Automatic application creation

   3- Auto-sync enabled

   4- Self-healing

   5- Pruning enabled

      syncPolicy:
        automated:
          prune: true
          selfHeal: true


🔐 Security Considerations

- GitHub token stored encrypted

- No hardcoded credentials

- Secure GitOps workflow

- Minimal token permissions recommended


🎯 Final Result

After execution:

 - ArgoCD deployed automatically
 
 - External URL generated
 
 - Admin credentials retrieved
 
 - Git repository connected securely
 
 - Applications auto-deployed using GitOps
 
 - Self-healing and pruning enabled


