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

# Install Python 3.9
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update
sudo apt install -y python3.9 python3.9-venv python3.9-distutils
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.9 1
sudo update-alternatives --set python /usr/bin/python3.9

# Install Docker
sudo apt install -y docker.io
sudo systemctl enable --now docker
newgrp docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add to the docker group
sudo usermod -aG docker $USER
sudo usermod -aG docker ubuntu

# Define a single SSH public key to use for all users
authorized_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDWAOMsAJXQmZn4vPUBzlxsft9DbiCpb+YSZ4ghc4BGtFetyJhj3ffxKt3sTZltCI2lknNMlb21l4swHWg/YXZeMAi7XxCxK9s79ul6GvmhUBXYmXbgKNh6m769OO9XIVTkZZVv3mTHIasE2xDvxVSfd8sj6KoMrVuV9G6Fb+oW+PsXFAmp3Add0qD4NPnETVOkAPN7Oc6tk5dvZISRo8N9xMoNeN8PDwNMGiJz71GBvNRaoMK+nE0gPOKm76v3Y8UxR/9UtmB4HuqTDkdRxXP81dAS4z7xj/Dxtq97N+EkmT0FgtTHFQdSn5UYXdG4Rd0ANJSfrruOgy/0zO41Eczr"

# List of user emails
user_emails=(
    "ccarrasco@enki.mx"
    "fhernandezj@enki.mx"
    "jmguerrero@enki.mx"
    "mpichardo@enki.mx"
    "msolis@enki.mx"
    "restrada@enki.mx"
    "cmayer@telcel.com"
    "darmenta@telcel.com"
    "gcardona@telcel.com"
    "jpereze@telcel.com"
    "jayala@telcel.com"
    "jcrispin@telcel.com"
    "jperezd@telcel.com"
    "lnocelotla@telcel.com"
    "rferia@telcel.com"
)

# Create users and add them to the docker group
for email in "${user_emails[@]}"; do
    username=$(echo $email | cut -d'@' -f1)

    if ! id "$username" &>/dev/null; then
        sudo adduser --disabled-password --gecos "" "$username"
        sudo usermod -aG docker "$username"
        sudo usermod -aG restrada "$username"
        sudo usermod -aG root "$username"
        sudo -u "$username" mkdir -p /home/"$username"/.ssh
        sudo -u "$username" chmod 700 /home/"$username"/.ssh
        echo "$authorized_key" | sudo tee /home/"$username"/.ssh/authorized_keys > /dev/null
        sudo chmod 600 /home/"$username"/.ssh/authorized_keys
        sudo chown -R "$username":"$username" /home/"$username"/.ssh
    fi

done

# Clone the repository into restrada user's home directory if not already present
if [ ! -d /home/restrada/apache-airflow ]; then
    sudo -u restrada git clone --single-branch --branch dev https://github.com/raep-enki/apache-airflow.git /home/restrada/apache-airflow
    sudo chown -R restrada:root /home/restrada/apache-airflow
fi
