#!/bin/bash

NOP=$1

#cp profile_configtx.yaml configtx.yaml

#Updating Profiles Section
for ((i=3; i<=$NOP; i++))
do
	echo "                    - *Org$i" >> configtx.yaml
done
