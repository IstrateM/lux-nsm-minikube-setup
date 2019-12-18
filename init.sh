#!/bin/bash
#Script used to quicly set-up minikube on Ubuntu 18.04
# Generate Luxoft certificate
echo -n | openssl s_client -showcerts -connect dl.k8s.io:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > kube.chain.pem

# Extract the last certificate
csplit -f htf kube.chain.pem '/-----BEGIN CERTIFICATE-----/' '{*}' | sudo cat $(ls htf* | sort | tail -1) > luxoft_root_ca.crt && rm -rf htf*

#Remove any existing docker app
sudo apt-get remove docker docker-engine docker.io containerd runc

#Upgrade apt-get
sudo apt-get update

#Install packages to allow apt to use a repository over HTTPS
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

#Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

#Set-up stable repository
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

#Install docker engine
sudo apt-get install docker-ce docker-ce-cli containerd.io

#Verify docker got installed correctly
sudo docker run hello-world

#Add user to docker group
sudo usermod -aG docker your-user

#Install kubectl
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

#Intall VirtualBox

#Add source to /etc/apt/sources.list
#deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian <mydist> contrib
echo 'deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian bionic contrib' >> /etc/apt/sources.list

#Download and register keys to oracle vbox
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -

#Install VirtualBox
sudo apt-get update
sudo apt-get install virtualbox-6.0

#Verify Installation
virsh list --all

#Install Minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube

#Add minikube executable to path
sudo mkdir -p /usr/local/bin/
sudo install minikube /usr/local/bin/

#Add luxoft certificate to minikube

sudo cp /usr/local/share/ca-certificates/luxoft/luxoft_root_ca.crt ~/.minikube/files/etc/ssl/certs/luxoft_root_ca.crt

#Reboot machine
sudo reboot

#Start minikube
#minikube start --vm-driver=virtualbox


