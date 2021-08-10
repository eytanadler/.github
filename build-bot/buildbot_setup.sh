#!/bin/sh

### Reading the input token for docker install
if [ "$1" != "" ]; then
    TOKEN=$1
else
    echo "Enter GitHub token as positional argument"
fi

### Base packages installation
sudo apt-get update && sudo apt-get -y upgrade
sudo apt-get install openssh-server vim cmake build-essential

### Install Docker
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
# add docker to the sudo group
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
# test that docker works
docker run hello-world
if [ $? -ne 0 ]; then
    echo "Docker was not installed correctly"
    exit 1
fi

# enable the docker service
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Create a folder
mkdir $HOME/actions-runner && cd $HOME/actions-runner
# Download the latest runner package
curl -o actions-runner-linux-x64-2.279.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.279.0/actions-runner-linux-x64-2.279.0.tar.gz
# Optional: Validate the hash
echo "50d21db4831afe4998332113b9facc3a31188f2d0c7ed258abf6a0b67674413a  actions-runner-linux-x64-2.279.0.tar.gz" | shasum -a 256 -c
if [ $? -ne 0 ]; then
    echo "The runner was not downloaded correctly"
    exit 1
fi

# Extract the installer
tar xzf ./actions-runner-linux-x64-2.279.0.tar.gz
# Create the runner and start the configuration experience
./config.sh --url https://github.com/mdolab --token $TOKEN --unattended
# Set the runner as a service
sudo ./svc.sh install
# Start the service
sudo ./svc.sh start
