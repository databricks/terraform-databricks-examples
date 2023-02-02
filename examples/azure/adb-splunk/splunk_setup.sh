  #! /bin/bash
  sudo apt update
  sudo apt install docker.io -y
  sudo apt install docker-compose -y
  sudo docker run -d -p 8000:8000 -p 8089:8089 -p 9997:9997 -e "SPLUNK_START_ARGS=--accept-license" -e "SPLUNK_PASSWORD=password" -e "SPLUNK_APPS_URL=https://adls5a0e9o.blob.core.windows.net/cnt1/databricks-add-on-for-splunk_110.tgz" --name splunk splunk/splunk:latest
