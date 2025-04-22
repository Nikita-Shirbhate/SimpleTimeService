# SimpleTimeService

## Overview

SimpleTimeService is a containerized web application that provides a simple time service. It is deployed on AWS using Terraform and ECS Fargate. The application is accessible via an Application Load Balancer (ALB) and returns the current timestamp and the visitor's IP address in JSON format.

## Project Structure

```
SimpleTimeService/
├── Dockerfile                # Dockerfile for building the application image
├── Readme.md                 # Documentation for the project
├── app/
│   ├── app.py                # Flask application code
│   ├── requirements.txt      # Python dependencies
│   └── wsgi.py               # WSGI entry point for the application
├── terraform/
│   ├── main.tf               # Terraform configuration for AWS resources
│   ├── outputs.tf            # Terraform outputs
│   ├── terraform.tfvars      # Terraform variables (user-specific configuration)
│   └── variables.tf          # Terraform variable definitions
```

## Key Features

- **Infrastructure as Code (IaC):** Uses Terraform to define and provision AWS resources.
- **Containerized Application:** The application is packaged as a Docker container.
- **AWS ECS Fargate:** Runs the application on a serverless container orchestration platform.
- **Load Balancer:** Configured with an ALB for routing traffic to the ECS service.
- **Scalable Architecture:** Supports scaling and high availability with public and private subnets.

## Application Details

- **Language:** Python
- **Framework:** Flask
- **Port:** 5000
- **Response:** JSON object with the current timestamp and visitor's IP address.

## Resources Created

- **VPC:** A Virtual Private Cloud with public and private subnets.
- **Subnets:** Two public and two private subnets across availability zones.
- **Internet Gateway & NAT Gateway:** For internet access in public and private subnets.
- **ECS Cluster:** Hosts the containerized application.
- **IAM Role:** Grants permissions for ECS task execution.
- **Security Group:** Configures inbound and outbound traffic rules.
- **Load Balancer:** Routes traffic to the ECS service.

## Prerequisites

- **AWS CLI:** Installed and configured with appropriate credentials.
- **Terraform:** Installed on your local machine.
- **Docker:** Installed for building the container image.

## Deployment Steps

1. **Clone the Repository:**
    ```bash
    git clone https://github.com/your-repo/SimpleTimeService.git
    cd SimpleTimeService
    ```

2. **Build the Docker Image:**
    ```bash
    docker build -t simpletime-service .
    ```

3. **Push the Docker Image to a Registry:**
    - Tag the image:
      ```bash
      docker tag simpletime-service:latest <your-dockerhub-username>/simpletime-service:latest
      ```
    - Push the image:
      ```bash
      docker push <your-dockerhub-username>/simpletime-service:latest
      ```

4. **Configure Terraform:**
    - Update `terraform/terraform.tfvars` with your AWS credentials and desired configuration.

5. **Deploy Infrastructure:**
    ```bash
    cd terraform
    terraform init
    terraform apply
    ```

6. **Access the Service:**
    - Retrieve the ALB DNS name from Terraform outputs:
      ```bash
      terraform output alb_dns_name
      ```
    - Open the DNS name in your browser to access the service.

## Example Response

When accessing the service, you will receive a JSON response like this:
```json
{
  "timestamp": "2025-04-22T12:34:56Z",
  "ip": "203.0.113.42"
}
```

## Cleanup

To destroy the infrastructure and avoid incurring costs:

```bash
cd terraform
terraform destroy
```

Here is a Jenkins pipeline script (Jenkinsfile) that automates the process of building a Docker image, pushing it to Docker Hub, and deploying infrastructure using Terraform

```
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "your-dockerhub-username/simpletime-service:latest"
        DOCKER_CREDENTIALS_ID = "docker-hub-credentials" // Jenkins credentials ID for Docker Hub
        AWS_CREDENTIALS_ID = "aws-credentials"           // Jenkins credentials ID for AWS
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Clone the repository
                git branch: 'main', url: 'https://github.com/your-repo/SimpleTimeService.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image
                    sh 'docker build -t ${DOCKER_IMAGE} .'
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    // Log in to Docker Hub and push the image
                    withDockerRegistry([credentialsId: DOCKER_CREDENTIALS_ID]) {
                        sh 'docker push ${DOCKER_IMAGE}'
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    // Initialize Terraform
                    dir('terraform') {
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS_ID]]) {
                            sh 'terraform init'
                        }
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    // Apply Terraform configuration
                    dir('terraform') {
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS_ID]]) {
                            sh 'terraform apply -auto-approve'
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            // Clean up workspace
            cleanWs()
        }
    }
}
```
