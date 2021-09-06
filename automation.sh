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

#check and update the inventory file with the metadat of archived logs
FILE=/var/www/html/inventory.html
if test -f "$FILE"; then
    echo "$FILE exists."
    
    {
    echo "<table>"
    echo "<tr>"	    
    echo "<td style="padding:20px">httpd-logs</th>"
    echo "<td style="padding:20px">$timestamp</th>"
    echo "<td style="padding:20px">tar</th>"
    echo "<td style="padding:20px">$(du -sh /tmp/Pradeep-httpd-logs-06092021-130134.tar | awk '{print $1}')</th>"
    echo "</tr>"
    echo "</table>"
    }>>$FILE
else
	{
echo "<html>"
echo "<table>"
echo "<tr>"
echo "<th style="padding:20px">Log Type</th>"
echo "<th style="padding:20px">Date Created</th>"
echo "<th style="padding:20px">Type</th>"
echo "<th style="padding:20px">Size</th>"
echo "</tr>"
echo "<tr>"
echo "<td style="padding:20px">httpd-logs</th>"
echo "<td style="padding:20px">$timestamp</th>"
echo "<td style="padding:20px">tar</th>"
echo "<td style="padding:20px">$(du -sh /tmp/Pradeep-httpd-logs-06092021-130134.tar | awk '{print $1}')</th>"
echo "</tr>"

echo "</table>"
echo "</html>"

}>> $FILE
fi


