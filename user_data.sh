#!/bin/bash

echo "Hello, World" > index.html
sudo apt-get update
sudo apt install -y default-jre
sudo apt install -y maven
sudo apt-get update
sudo apt-get install -y mysql-server
systemctl start mysql
systemctl enable mysql
sudo apt-get update
sudo apt install -y awscli
aws s3 cp s3://spring-application-code/ . --recursive
mvn clean package