#!/bin/bash
# It lives at dbfs:/scripts/external_metastore_init.sh
# Loads environment variables to determine the correct JDBC driver to use.
# to use secrets in env var inside init script, we need to create a few local vars to hold them
source /etc/environment

PASSWORD="$HIVE_PASSWORD"
URL="$HIVE_URL"
USER="$HIVE_USER"

# Quoting the label (i.e. EOF) with single quotes to disable variable interpolation.
cat << EOF >>/databricks/driver/conf/00-custom-spark.conf
    # Hive specific configuration options.
    # spark.hadoop prefix is added to make sure these Hive specific options will propagate to the metastore client.
    # JDBC connect string for a JDBC metastore
    "spark.hadoop.javax.jdo.option.ConnectionURL"="$URL"

    # Username to use against metastore database
    "spark.hadoop.javax.jdo.option.ConnectionUserName"="$USER"

    # Password to use against metastore database
    "spark.hadoop.javax.jdo.option.ConnectionPassword"="$PASSWORD"

    # Driver class name for a JDBC metastore
    "spark.hadoop.javax.jdo.option.ConnectionDriverName" = "com.microsoft.sqlserver.jdbc.SQLServerDriver"

    # Spark specific configuration options
    "spark.sql.hive.metastore.version" = "3.1.0"
    # Skip this one if <hive-version> is 0.13.x.
    "spark.sql.hive.metastore.jars" = "/dbfs/tmp/hive/3-1-0/lib/*"
EOF
