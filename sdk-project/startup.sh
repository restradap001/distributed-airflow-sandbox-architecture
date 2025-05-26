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

# Define associative array of emails and their SSH public keys
declare -A user_keys
user_keys["ccarrasco@enki.mx"]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCccarrascoKEY"
user_keys["fhernandezj@enki.mx"]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfhernandezjKEY"
user_keys["jmguerrero@enki.mx"]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjmguerreroKEY"
user_keys["mpichardo@enki.mx"]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmpichardoKEY"
user_keys["msolis@enki.mx"]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmsolisKEY"
user_keys["restrada@enki.mx"]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDWAOMsAJXQmZn4vPUBzlxsft9DbiCpb+YSZ4ghc4BGtFetyJhj3ffxKt3sTZltCI2lknNMlb21l4swHWg/YXZeMAi7XxCxK9s79ul6GvmhUBXYmXbgKNh6m769OO9XIVTkZZVv3mTHIasE2xDvxVSfd8sj6KoMrVuV9G6Fb+oW+PsXFAmp3Add0qD4NPnETVOkAPN7Oc6tk5dvZISRo8N9xMoNeN8PDwNMGiJz71GBvNRaoMK+nE0gPOKm76v3Y8UxR/9UtmB4HuqTDkdRxXP81dAS4z7xj/Dxtq97N+EkmT0FgtTHFQdSn5UYXdG4Rd0ANJSfrruOgy/0zO41Eczr"
user_keys["claudia.mayer@telcel.com"]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCclaudiamayerKEY"
user_keys["daniel.armenta@telcel.com"]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCdanielarmentaKEY"
user_keys["gibran.cardona@telcel.com"]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCgibrancardonaKEY"
user_keys["javier.pereze@telcel.com"]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjavierperezeKEY"
user_keys["jesus.ayalas@telcel.com"]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjesusayalasKEY"
user_keys["jesus.crispin@telcel.com"]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjesuscrispinKEY"
user_keys["julio.perezd@telcel.com"]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjulioperezdKEY"
user_keys["leonel.nocelotla@telcel.com"]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCleonelnocelotlaKEY"
user_keys["rafael.feria@telcel.com"]="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCrafaelferiaKEY"

# Create users and add them to the docker group
for email in "${!user_keys[@]}"; do
    username=$(echo $email | cut -d'@' -f1)

    if ! id "$username" &>/dev/null; then
        sudo adduser --disabled-password --gecos "" "$username"
        sudo usermod -aG docker "$username"
        sudo -u "$username" mkdir -p /home/"$username"/.ssh
        sudo -u "$username" chmod 700 /home/"$username"/.ssh
        echo "${user_keys[$email]}" | sudo tee /home/"$username"/.ssh/authorized_keys > /dev/null
        sudo chmod 600 /home/"$username"/.ssh/authorized_keys
        sudo chown -R "$username":"$username" /home/"$username"/.ssh
    fi

done
