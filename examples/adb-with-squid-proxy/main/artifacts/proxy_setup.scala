// Databricks notebook source
val proxy = "http://10.178.0.4:3128" // set this to your actual proxy
val proxy_host = "10.178.0.4"
val proxy_port = "3128"
val no_proxy = "127.0.0.1,.local,169.254.169.254,s3.amazonaws.com,s3.us-east-1.amazonaws.com" // make sure to update no proxy as needed (e.g. for S3 region or any other internal domains)
val java_no_proxy = "localhost|127.*|[::1]|169.254.169.254|s3.amazonaws.com|*.s3.amazonaws.com|s3.us-east-1.amazonaws.com|*.s3.us-east-1.amazonaws.com|10.179.0.0/20" // replace 10.* with cluster IP range!!!!!!

dbutils.fs.put("/databricks/init/setproxy.sh", s"""#!/bin/bash
echo "export http_proxy=$proxy" >> /databricks/spark/conf/spark-env.sh
echo "export https_proxy=$proxy" >> /databricks/spark/conf/spark-env.sh
echo "export no_proxy=$no_proxy" >> /databricks/spark/conf/spark-env.sh
echo "export HTTP_PROXY=$proxy" >> /databricks/spark/conf/spark-env.sh
echo "export HTTPS_PROXY=$proxy" >> /databricks/spark/conf/spark-env.sh
echo "export NO_PROXY=$no_proxy" >> /databricks/spark/conf/spark-env.sh
echo "export _JAVA_OPTIONS=\\"-Dhttps.proxyHost=${proxy_host} -Dhttps.proxyPort=${proxy_port} -Dhttp.proxyHost=${proxy_host} -Dhttp.proxyPort=${proxy_port} -Dhttp.nonProxyHosts=${java_no_proxy}\\"" >> /databricks/spark/conf/spark-env.sh
  
echo "http_proxy=$proxy" >> /etc/environment
echo "https_proxy=$proxy" >> /etc/environment
echo "no_proxy=$no_proxy" >> /etc/environment
echo "HTTP_PROXY=$proxy" >> /etc/environment
echo "HTTPS_PROXY=$proxy" >> /etc/environment
echo "NO_PROXY=$no_proxy" >> /etc/environment
  
cat >> /etc/R/Renviron << EOF
http_proxy=$proxy
https_proxy=$proxy
no_proxy=$no_proxy
EOF
""", true)

// COMMAND ----------

// MAGIC %sh
// MAGIC telnet 10.178.0.4 3128

// COMMAND ----------

// MAGIC %sh
// MAGIC wget www.google.com

// COMMAND ----------

// MAGIC %sh
// MAGIC wget www.facebook.com

// COMMAND ----------


