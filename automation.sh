#!/bin/bash
s3_bucket="upgrad-pradeep"
name="Pradeep"
timestamp=$(date '+%d%m%Y-%H%M%S')
#update of the package details and the package list
sudo apt update -y
#check if apache2 is installed else install apache2
apache_installed_status=$(apt list -a --installed apache2)
if [[ $apache_installed_status == *"apache2"* ]]; then
  echo $apache_installed_status
  service_enabled=$(systemctl list-unit-files --state=enabled | grep apache2)
  #if installed check if the apache2 is enabled
  if [[ $service_enabled == *"apache2.service"* ]]; then
	  echo $service_enabled
  else 
	  echo "Service not listed in enabled state. Enabling the service"
	  sudo systemctl enable apache2.service
  fi
else
	echo "apache2 NOT installed. Installing apache2"
	sudo apt install apache2 -y
fi
#check if apache2 is running else start it
apache_service_status=$(systemctl --type=service --state=running | grep apache2)
if [[ $apache_service_status == *"apache2"* ]]; then
          echo $apache_service_status
else
          echo "Service is not Running. Starting the service"
          sudo systemctl start apache2.service
fi
#The below section contains the logic to compress the apache2 log files and copy to s3-bucket
filename=$name-httpd-logs-$timestamp.tar
tar cvf $filename /var/log/apache2/*.log
mv $filename /tmp/$filename

#copy the logs to s3-bucket
aws s3 cp /tmp/${name}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${name}-httpd-logs-${timestamp}.tar


