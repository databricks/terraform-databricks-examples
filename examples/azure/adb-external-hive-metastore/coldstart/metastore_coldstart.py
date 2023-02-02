# Databricks notebook source
# uncomment below if you are to remove jars previously downloaded using this script
# dbutils.fs.rm('/tmp/hive',True)

# COMMAND ----------

# MAGIC %sh
# MAGIC export TARGET_HIVE_VERSION="3.1.0"
# MAGIC export TARGET_HADOOP_VERSION="2.7.2"
# MAGIC export TARGET_HIVE_HOME="/opt/apache-hive-${TARGET_HIVE_VERSION}-bin"
# MAGIC export TARGET_HADOOP_HOME="/opt/hadoop-${TARGET_HADOOP_VERSION}"
# MAGIC export JARS_DIRECTORY="/dbfs/tmp/hive/3-1-0/lib/"
# MAGIC
# MAGIC
# MAGIC if [ ! -d  "$TARGET_HADOOP_HOME" ]; then
# MAGIC   if [ ! -f hadoop-${TARGET_HADOOP_VERSION}.tar.gz ]; then
# MAGIC     wget https://archive.apache.org/dist/hadoop/common/hadoop-${TARGET_HADOOP_VERSION}/hadoop-${TARGET_HADOOP_VERSION}.tar.gz
# MAGIC   fi
# MAGIC   tar -xvzf hadoop-${TARGET_HADOOP_VERSION}.tar.gz --directory /opt
# MAGIC fi
# MAGIC if [ ! -d "$TARGET_HIVE_HOME" ]; then
# MAGIC   if [ ! -f  apache-hive-${TARGET_HIVE_VERSION}-bin.tar.gz ]; then
# MAGIC     wget https://archive.apache.org/dist/hive/hive-${TARGET_HIVE_VERSION}/apache-hive-${TARGET_HIVE_VERSION}-bin.tar.gz
# MAGIC   fi
# MAGIC   tar -xvzf apache-hive-${TARGET_HIVE_VERSION}-bin.tar.gz --directory /opt
# MAGIC fi
# MAGIC ## https://www.microsoft.com/en-us/download/details.aspx?id=11774
# MAGIC if [ ! -f sqljdbc_9.2.1.0_enu.tar.gz ]; then
# MAGIC   wget https://download.microsoft.com/download/4/c/3/4c31fbc1-62cc-4a0b-932a-b38ca31cd410/sqljdbc_9.2.1.0_enu.tar.gz
# MAGIC fi
# MAGIC tar -xvzf sqljdbc_9.2.1.0_enu.tar.gz --directory /opt
# MAGIC if [ ! -f oauth2-oidc-sdk-9.4.jar ]; then
# MAGIC   wget https://repo1.maven.org/maven2/com/nimbusds/oauth2-oidc-sdk/9.4/oauth2-oidc-sdk-9.4.jar
# MAGIC fi
# MAGIC if [ ! -f msal4j-1.10.0.jar ]; then
# MAGIC   wget https://repo1.maven.org/maven2/com/microsoft/azure/msal4j/1.10.0/msal4j-1.10.0.jar
# MAGIC fi
# MAGIC cp oauth2-oidc-sdk-9.4.jar msal4j-1.10.0.jar /opt/sqljdbc_9.2/enu/mssql-jdbc-9.2.1.jre8.jar ${TARGET_HIVE_HOME}/lib/
# MAGIC
# MAGIC echo "Copying necessary jars into ${JARS_DIRECTORY}"
# MAGIC mkdir -p ${JARS_DIRECTORY}
# MAGIC cp -r ${TARGET_HIVE_HOME}/lib/. ${JARS_DIRECTORY}
# MAGIC cp -r ${TARGET_HADOOP_HOME}/share/hadoop/common/lib/. ${JARS_DIRECTORY}
# MAGIC ls -l ${JARS_DIRECTORY}

# COMMAND ----------

# DBTITLE 1,Test Hive Environment Variables - set these vars on cluster UI --> Advance tab
# MAGIC %sh
# MAGIC echo $HIVE_URL
# MAGIC echo $HIVE_USER
# MAGIC echo $HIVE_PASSWORD

# COMMAND ----------

# DBTITLE 1,Initialize hive schema, you must use HIVE_HOME and HADOOP_HOME env var
# MAGIC %sh
# MAGIC export TARGET_HIVE_VERSION="3.1.0"
# MAGIC export TARGET_HADOOP_VERSION="2.7.2"
# MAGIC export TARGET_HIVE_HOME="/opt/apache-hive-${TARGET_HIVE_VERSION}-bin"
# MAGIC export TARGET_HADOOP_HOME="/opt/hadoop-${TARGET_HADOOP_VERSION}"
# MAGIC export SQLDB_DRIVER="com.microsoft.sqlserver.jdbc.SQLServerDriver"
# MAGIC
# MAGIC export HIVE_HOME=$TARGET_HIVE_HOME
# MAGIC export HADOOP_HOME=$TARGET_HADOOP_HOME
# MAGIC
# MAGIC $TARGET_HIVE_HOME/bin/schematool -dbType mssql -url $HIVE_URL -passWord $HIVE_PASSWORD -userName $HIVE_USER -driver $SQLDB_DRIVER -initSchema

# COMMAND ----------

# DBTITLE 1,Validate hive is initialized, you must use HIVE_HOME and HADOOP_HOME env var
# MAGIC %sh
# MAGIC export TARGET_HIVE_VERSION="3.1.0"
# MAGIC export TARGET_HADOOP_VERSION="2.7.2"
# MAGIC export TARGET_HIVE_HOME="/opt/apache-hive-${TARGET_HIVE_VERSION}-bin"
# MAGIC export TARGET_HADOOP_HOME="/opt/hadoop-${TARGET_HADOOP_VERSION}"
# MAGIC export SQLDB_DRIVER="com.microsoft.sqlserver.jdbc.SQLServerDriver"
# MAGIC
# MAGIC export HIVE_HOME=$TARGET_HIVE_HOME
# MAGIC export HADOOP_HOME=$TARGET_HADOOP_HOME
# MAGIC
# MAGIC $TARGET_HIVE_HOME/bin/schematool -dbType mssql -url $HIVE_URL -passWord $HIVE_PASSWORD -userName $HIVE_USER -driver $SQLDB_DRIVER -info

# COMMAND ----------

# MAGIC %sql
# MAGIC show databases;
