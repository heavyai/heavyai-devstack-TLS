#!/bin/bash

# Reading .env file or setting defaults
if [ -f ./.env ]; then
    echo "Reading .env file"
    source ./.env
else
    echo ".env file does not exist. Using defaults"
fi
HEAVY_CONF_TEMPLATE="./templates/heavy.conf.complete"
HEAVYIQ_CONF_TEMPLATE="./templates/heavy.conf.complete"
IMMERSE_CONF_TEMPLATE="./templates/heavy.conf.complete"
IMMERSE_SERVERS_JSON_TEMPLATE="./templates/servers.json"
DOCKER_FILE_TEMPLATE="./templates/docker-compose-soa.yml"

HEAVYDB_SERVICE_NAME="heavydb"
IMMERSE_SERVICE_NAME="immerse"
IQ_SERVICE_NAME="iq"
CONFIG_STAGING_LOCATION="./test"

: ${HEAVY_CONFIG_BASE:="/var/lib/heavyai"} #typically /var/lib/heavyai

HEAVYDB_CONFIG_LOCATION="${HEAVY_CONFIG_BASE}/heavy.conf"  # assuming actual path for the config


: ${IMMERSE_PORT:="6273"}
: ${HEAVYDB_PORT:="6274"}
: ${HEAVYIQ_PORT:="6275"}
: ${HEAVYDB_BACKEND_PORT:="6278"}
: ${HEAVYDB_CALCITE_PORT:="6279"}

: ${HEAVY_IQ_CONFIG:="${HEAVY_CONFIG_BASE}/iq"}
: ${HEAVY_IMMERSE_CONFIG:="${HEAVY_CONFIG_BASE}/immerse"}

: ${HEAVY_STORAGE_DIR:="${HEAVY_CONFIG_BASE}/storage"}
: ${HEAVYDB_IMPORT_PATH:="${HEAVY_CONFIG_BASE}/import"}
: ${HEAVYDB_EXPORT_PATH:="${HEAVY_CONFIG_BASE}/export"}

: ${IMMERSE_SERVERS_JSON:="${HEAVY_IMMERSE_CONFIG}/servers.json"}
: ${HEAVYDB_BACKEND_URL:="http://$HEAVYDB_SERVICE_NAME:$HEAVYDB_BACKEND_PORT"}
: ${IQ_URL:="http://$IQ_SERVICE_NAME:$HEAVYIQ_PORT"}

: ${CONTAINER:="docker-internal.mapd.com/mapd/mapd-render:master"}

configureApp() {
    template_file=$1
    config_file=$2

    # Ensure the template exists
    if [ ! -f "$template_file" ]; then
        echo "Template file $template_file does not exist."
        return 1
    fi

    cp "$template_file" "$config_file"
    
    # Using alternative delimiters for sed to handle paths with slashes
    sed -i '' "s|{{IMMERSE_PORT}}|$IMMERSE_PORT|g" $config_file
    sed -i '' "s|{{HEAVYDB_CALCITE_PORT}}|$HEAVYDB_CALCITE_PORT|g" $config_file
    sed -i '' "s|{{HEAVYIQ_PORT}}|$HEAVYIQ_PORT|g" $config_file
    sed -i '' "s|{{HEAVYDB_PORT}}|$HEAVYDB_PORT|g" $config_file
    sed -i '' "s|{{HEAVYDB_BACKEND_PORT}}|$HEAVYDB_BACKEND_PORT|g" $config_file

    sed -i '' "s|{{HEAVY_STORAGE_DIR}}|$HEAVY_STORAGE_DIR|g" "$config_file"
    sed -i '' "s|{{HEAVYDB_IMPORT_PATH}}|$HEAVYDB_IMPORT_PATH|g" $config_file
    sed -i '' "s|{{HEAVYDB_EXPORT_PATH}}|$HEAVYDB_EXPORT_PATH|g" $config_file
    
    sed -i '' "s|{{HEAVY_IQ_CONFIG}}|$HEAVY_IQ_CONFIG|g" $config_file
    sed -i '' "s|{{HEAVY_IMMERSE_CONFIG}}|$HEAVY_IMMERSE_CONFIG|g" $config_file
    sed -i '' "s|{{HEAVYDB_CONFIG_LOCATION}}|$HEAVYDB_CONFIG_LOCATION|g" $config_file

    sed -i '' "s|{{IMMERSE_SERVERS_JSON}}|$IMMERSE_SERVERS_JSON|g" $config_file

    sed -i '' "s|{{HEAVYDB_BACKEND_URL}}|$HEAVYDB_BACKEND_URL|g" $config_file
    sed -i '' "s|{{IQ_URL}}|$IQ_URL|g" $config_file

    sed -i '' "s|{{HEAVYDB_SERVICE_NAME}}|$HEAVYDB_SERVICE_NAME|g" $config_file
    sed -i '' "s|{{IMMERSE_SERVICE_NAME}}|$IMMERSE_SERVICE_NAME|g" $config_file
    sed -i '' "s|{{IQ_SERVICE_NAME}}|$IQ_SERVICE_NAME|g" $config_file

    sed -i '' "s|{{CONTAINER}}|$CONTAINER|g" $config_file
}

setupInstall(){
    echo "Setting up the installation"
    sudo mkdir $HEAVY_CONFIG_BASE #typically /var/lib/heavyai
    chown -R $USER $HEAVY_CONFIG_BASE
    mkdir -p $HEAVYDB_IMPORT_PATH
    mkdir -p $HEAVYDB_EXPORT_PATH
    mkdir -p $HEAVY_IQ_CONFIG
    mkdir -p $HEAVY_IMMERSE_CONFIG

}

moveConfig(){
    echo "Moving the configuration files to the correct location"
    cp "$CONFIG_STAGING_LOCATION/heavy.conf" "$HEAVYDB_CONFIG_LOCATION"
    cp "$CONFIG_STAGING_LOCATION/heavy.conf" "$HEAVY_IMMERSE_CONFIG"
    cp "$CONFIG_STAGING_LOCATION/heavy.conf" "$HEAVY_IQ_CONFIG"
    cp "$CONFIG_STAGING_LOCATION/servers.json" "$IMMERSE_SERVERS_JSON"
    cp "$CONFIG_STAGING_LOCATION/docker-compose.yml" "../docker-compose.yml"
}

configureApp "$HEAVY_CONF_TEMPLATE" "$CONFIG_STAGING_LOCATION/heavy.conf"
configureApp "$DOCKER_FILE_TEMPLATE" "$CONFIG_STAGING_LOCATION/docker-compose.yml"
configureApp "$IMMERSE_SERVERS_JSON_TEMPLATE" "$CONFIG_STAGING_LOCATION/servers.json"
setupInstall
moveConfig