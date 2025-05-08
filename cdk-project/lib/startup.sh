#!/bin/bash

# Update the system
sudo apt update && sudo apt upgrade -y

# Install Essential Tools
sudo apt install -y curl wget unzip git

# Install AWS CLI
sudo apt install -y awscli

# Install AWS SSM Agent
sudo snap install amazon-ssm-agent --classic
sudo systemctl enable --now amazon-ssm-agent

# Install CloudFormation Helper Scripts
sudo apt install -y python3-pip
pip3 install aws-cfn-bootstrap

# Install Docker
sudo apt install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
sudo usermod -aG docker ubuntu
newgrp docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
