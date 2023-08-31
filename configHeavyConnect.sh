#!/bin/bash
cat > "/var/lib/heavyai/odbc/odbcinst.ini" <<odbcinstiniEnd
[ODBC Drivers]
Snowflake=Installed
Amazon Redshift (x64)=Installed
PostgreSQL=Installed

[Snowflake]
APILevel=1
ConnectFunctions=YYY
Description=Snowflake DSII
Driver=/usr/lib/snowflake/odbc/lib/libSnowflake.so

[Amazon Redshift (x64)]
Description=Redshift ODBC driver
Driver = /opt/amazon/redshiftodbc/lib/64/libamazonredshiftodbc64.so

[PostgreSQL]
Description=PostgreSQL ODBC driver
Driver=/usr/lib/x86_64-linux-gnu/odbc/psqlodbca.so
Setup=/usr/lib/x86_64-linux-gnu/odbc/libodbcpsqlS.so
Debug=0
CommLog=1
UsageCount=1

odbcinstiniEnd

cat > "/var/lib/heavyai/odbc/odbc.ini" <<odbciniEnd
[ODBC Data Sources]
Amazon Redshift DSN 64=Amazon Redshift (x64)
Snowflake = Snowflake
PostgreSQL=PostgreSQL

[Snowflake]
Description=SnowflakeDB
Driver=Snowflake
Locale=en-US
SERVER=lqa26912.snowflakecomputing.com
PORT=443
SSL=on
ACCOUNT=lqa26912

[PostgreSQL]
Description=Local default PostgreSQL database
Driver=PostgreSQL
Database=postgres
Servername=localhost
Port=5432

[Amazon Redshift DSN 64]
# This key is not necessary and is only to give a description of the data source.
Description=Amazon Redshift ODBC Driver (64-bit) DSN
# Driver: The location where the ODBC driver is installed to.
Driver=/opt/amazon/redshiftodbc/lib/64/libamazonredshiftodbc64.so

# Required: These values can also be specified in the connection string.
Server=[Server]
Port=[Port]
Database=[Database]
locale=en-US

odbciniEnd
