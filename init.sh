#!/bin/bash
#Script used to quicly set-up minikube on Ubuntu 18.04
# Generate Luxoft certificate

# Check virtualization support in Linux
if [ -z "$(grep -E --color 'vmx|svm' /proc/cpuinfo)" ]; then
  echo "No Virtualization support in Linux"
  exit 1
else
  echo "Virtualization support is enabled"
fi

# Check if curl is installed
curl --version >/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "curl is installed"
else
  echo "curl is not installed"
  sudo apt install curl
fi

# Extract the last certificate
echo -n | openssl s_client -showcerts -connect dl.k8s.io:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' >kube.chain.pem
csplit -f htf kube.chain.pem '/-----BEGIN CERTIFICATE-----/' '{*}' | sudo cat $(ls htf* | sort | tail -1) >luxoft_root_ca.crt && rm -rf htf*

#Upgrade apt-get
sudo apt-get update

#Install packages to allow apt to use a repository over HTTPS
sudo apt-get install \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common

#Remove any existing docker app
docker --version >/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "docker is installed"
  sudo apt-get remove docker docker-engine docker.io containerd runc
else
  echo "docker is not installed"
fi

#Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

#Set-up stable repository
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

#Install docker engine
sudo apt-get install docker-ce docker-ce-cli containerd.io

#Add user to docker group
sudo usermod -aG docker your-user

#Verify docker got installed correctly
sudo docker run hello-world >/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "docker is installed"
else
  echo "docker is not installed correctly"
  exit 1
fi

#Install kubectl
kubectl >/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "kubectl is installed"
else
  sudo apt-get update && sudo apt-get install -y apt-transport-https
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update
  sudo apt-get install -y kubectl
fi

# Check if VirtualBox is installed
vboxmanage --version > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "VirtualBox already installed"
else
    echo "VirtualBox is not installed"
    #Add the following line to your /etc/apt/sources.list
    sudo add-apt-repository "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"

    wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
    wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
    sudo apt-get update
    sudo apt-get install virtualbox-6.0
fi

#Install Minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 &&
  chmod +x minikube

#Add minikube executable to path
sudo mkdir -p /usr/local/bin/
sudo install minikube /usr/local/bin/

#Add luxoft certificate to minikube
sudo cp /usr/local/share/ca-certificates/luxoft/luxoft_root_ca.crt ~/.minikube/files/etc/ssl/certs/luxoft_root_ca.crt

#Start minikube
minikube start
