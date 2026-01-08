#!/bin/bash

# RADIUS Authentication Client Start Script
# This script starts the Seagull RADIUS authentication client

SEAGULL_HOME="/home/ankit/opt/seagull/diameter"

# Set library path for Seagull shared libraries
export LD_LIBRARY_PATH=/usr/local/bin:$LD_LIBRARY_PATH

echo "Starting RADIUS Authentication Client..."
echo "Configuration: config/radius/conf.auth-client.xml"
echo "Dictionary: config/radius/radius-dictionary.xml"
echo "Scenario: scenario/radius/radius-auth.client.xml"
echo ""

cd "$SEAGULL_HOME"

seagull -conf config/radius/conf.auth-client.xml \
        -dico config/radius/radius-dictionary.xml \
        -scen scenario/radius/radius-auth.client.xml \
        -log logs/radius-auth-client.log \
        -llevel ET

echo ""
echo "Client stopped."
