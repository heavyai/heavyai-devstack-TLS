#!/bin/bash
source ../config.sh

TMP_DIR="/var/lib/heavyai/import"

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "AWS Credentials are not set in the config.sh file.  Please update these to enable connection to AWS based assets"
    exit

fi

if [ $# -eq 0 ]; then
    echo "Usage:  loadDataPackage <packageFile.json>"
    exit
else
    PACKAGE_NAME=$1
fi

aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile demo \
&& aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile demo \
&& aws configure set region "$AWS_REGION" --profile demo \
&& aws configure set output "json" --profile demo

# Load Data Dump Files
while read TABLE_NAME && read filetype && read FILEPATH; do

    SQL="
        RESTORE TABLE ${TABLE_NAME} 
        FROM '$FILEPATH'
        WITH (COMPRESSION='${filetype}', 
        S3_REGION='$AWS_REGION', 
        S3_ACCESS_KEY='$AWS_ACCESS_KEY_ID', 
        S3_SECRET_KEY='$AWS_SECRET_ACCESS_KEY');"

    #echo "statement" $SQL
    HEAVY_SQL_COMMAND="/opt/heavyai/bin/heavysql -u admin -p HyperInteractive"
    echo $SQL | docker-compose exec -T heavyaiserver $HEAVY_SQL_COMMAND
done < <(jq -r '.dataFiles[] | .tablename, .filetype, .filepath' ./$PACKAGE_NAME)

# Load Dashboard Files
while read filename && read name && read FILEPATH; do
    if [ -z $filename ];then
        echo "No Dashboards found"
    else    
        aws s3 cp $FILEPATH/$filename $TMP_DIR/.
        SQL="\import_dashboard $name $TMP_DIR/$filename"
        echo $SQL | docker-compose exec -T heavyaiserver $HEAVY_SQL_COMMAND
    fi
done < <(jq -r '.dashboards[] | .filename, .name, .filepath' ./$PACKAGE_NAME)

