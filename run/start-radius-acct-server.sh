#!/bin/bash

# RADIUS Accounting Server Start Script
# This script starts the Seagull RADIUS accounting server

SEAGULL_HOME="/home/ankit/opt/seagull/diameter"

# Set library path for Seagull shared libraries
export LD_LIBRARY_PATH=/usr/local/bin:$LD_LIBRARY_PATH

echo "Starting RADIUS Accounting Server..."
echo "Configuration: config/radius/conf.acct-server.xml"
echo "Dictionary: config/radius/radius-dictionary.xml"
echo "Scenario: scenario/radius/radius-acct.server.xml"
echo ""

cd "$SEAGULL_HOME"

seagull -conf config/radius/conf.acct-server.xml \
        -dico config/radius/radius-dictionary.xml \
        -scen scenario/radius/radius-acct.server.xml \
        -log logs/radius-acct-server.log \
        -llevel ET

echo ""
echo "Server stopped."
