#!/bin/bash
PRFX="/home/pi/Desktop/SoilAirSensors/data/raw/"
DATE=`date '+%Y-%-m-%-d' -d "yesterday"`
AIR_FILE=$PRFX"airdata_"$DATE".dat"
SOIL_FILE=$PRFX"soildata-py_"$DATE".dat"
PSWD="YOUR_PASSWORD_PHRASE"

echo "sending "$AIR_FILE
sshpass -p '$PSWD' scp $AIR_FILE raspberrypi3bp:$PRFX
echo "sending "$SOIL_FILE
sshpass -p '$PSWD' scp $SOIL_FILE raspberrypi3bp:$PRFX
