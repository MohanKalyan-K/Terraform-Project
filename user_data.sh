#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
echo "Public Instance: $INSTANCE_ID" > /var/www/html/index.html
sudo yum install openssh -y 
sudo systemctl start sshd

