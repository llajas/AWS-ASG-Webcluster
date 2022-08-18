#!/bin/bash

# Create mount volume for logs
  sudo su - root
  mkfs.ext4 /dev/sdf
  mount -t ext4 /dev/sdf /var/log

# Install and start nginx web server
  yum search nginx 
  amazon-linux-extras install nginx1 -y
  systemctl start nginx
  systemctl enable nginx
  
# Print the hostname into the nginx homepage  
  sudo echo Hello from `hostname -f`! Lauren here! > /usr/share/nginx/html/index.html

  