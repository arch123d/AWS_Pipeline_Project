#!/bin/bash 
# This installs the CodeDeploy agent and its prerequisites on Ubuntu 22.04.  
sudo apt-get update 
sudo apt-get install ruby wget -y 
cd /tmp
# wget https://bucket-name.s3.region-identifier.amazonaws.com/latest/install
wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
sudo chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent start
sudo systemctl enable codedeploy-agent
sudo service codedeploy-agent status
