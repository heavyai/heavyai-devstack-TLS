#!/bin/bash
#PostgreSQL Driver and controller
apt-get update && apt-get install -y odbc-postgresql unixodbc
cd /tmp
# Snowflake Driver
wget https://sfc-repo.snowflakecomputing.com/odbc/linux/3.1.0/snowflake-odbc-3.1.0.x86_64.deb
dpkg -i snowflake-odbc-3.1.0.x86_64.deb
rm ./snowflake-odbc-3.1.0.x86_64.deb
# Redshift Driver
wget https://s3.amazonaws.com/redshift-downloads/drivers/odbc/1.4.65.1000/AmazonRedshiftODBC-64-bit-1.4.65.1000-1.x86_64.deb
dpkg -i AmazonRedshiftODBC-64-bit-1.4.65.1000-1.x86_64.deb
rm ./AmazonRedshiftODBC-64-bit-1.4.65.1000-1.x86_64.deb