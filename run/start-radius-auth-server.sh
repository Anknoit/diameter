#!/bin/bash

# RADIUS Authentication Server Start Script
# This script starts the Seagull RADIUS authentication server

SEAGULL_HOME="/home/ankit/opt/seagull/diameter"

# Set library path for Seagull shared libraries
export LD_LIBRARY_PATH=/usr/local/bin:$LD_LIBRARY_PATH

echo "Starting RADIUS Authentication Server..."
echo "Configuration: config/radius/conf.auth-server.xml"
echo "Dictionary: config/radius/radius-dictionary.xml"
echo "Scenario: scenario/radius/radius-auth.server.xml"
echo ""

cd "$SEAGULL_HOME"

seagull -conf config/radius/conf.auth-server.xml \
        -dico config/radius/radius-dictionary.xml \
        -scen scenario/radius/radius-auth.server.xml \
        -log logs/radius-auth-server.log \
        -llevel ET

echo ""
echo "Server stopped."
