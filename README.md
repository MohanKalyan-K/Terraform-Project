# Terraform AWS Infrastructure Setup

## Overview

This Terraform configuration sets up a scalable AWS infrastructure including a VPC, public and private subnets, NAT gateway, security groups, EC2 instances, and an Application Load Balancer (ALB). The setup is designed for web applications that require public access and private backend services.

## Components

- **VPC**: A Virtual Private Cloud with CIDR block specified by `var.vpc`.
- **Subnets**:
  - **Public Subnet 1** (`var.sub_pub1`): Located in `us-east-1a`.
  - **Public Subnet 2** (`var.sub_pub2`): Located in `us-east-1b`.
  - **Private Subnet** (`var.sub_priv`): Located in `us-east-1a`.
- **Internet Gateway**: Provides internet access to public subnets.
- **NAT Gateway**: Allows instances in the private subnet to access the internet.
- **Security Groups**:
  - **Public Security Group**: Allows HTTP, HTTPS, SSH, and RDP traffic.
  - **Private Security Group**: Allows inbound traffic from public subnets.
- **EC2 Instances**:
  - **Public Instance 1**
  - **Public Instance 2**
  - **Private Instance**
- **Application Load Balancer**: Distributes incoming HTTP traffic to the public instances.
- **Elastic IP**: Allocated for NAT Gateway.

## Prerequisites

- **AWS CLI**: Ensure you have the AWS CLI configured with appropriate credentials.
- **Terraform**: Ensure Terraform is installed on your machine.

