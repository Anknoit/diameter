#!/bin/bash

# RADIUS Accounting Client Start Script
# This script starts the Seagull RADIUS accounting client

SEAGULL_HOME="/home/ankit/opt/seagull/diameter"

# Set library path for Seagull shared libraries
export LD_LIBRARY_PATH=/usr/local/bin:$LD_LIBRARY_PATH

echo "Starting RADIUS Accounting Client..."
echo "Configuration: config/radius/conf.acct-client.xml"
echo "Dictionary: config/radius/radius-dictionary.xml"
echo "Scenario: scenario/radius/radius-accounting.client.xml"
echo ""

cd "$SEAGULL_HOME"

seagull -conf config/radius/conf.acct-client.xml \
        -dico config/radius/radius-dictionary.xml \
        -scen scenario/radius/radius-accounting.client.xml \
        -log logs/radius-acct-client.log \
        -llevel ET

echo ""
echo "Client stopped."
