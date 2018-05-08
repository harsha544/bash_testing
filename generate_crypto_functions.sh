#!/bin/bash
#set -x

NOP=$1

if [ $NOP -gt 2 ]
then
  echo "Updating Crypto Material"
  # pushd ../sampleconfig/
  cp crypto-config.yaml.orig crypto-config.yaml
  for ((i=3; i<=$NOP; i++))
  do
	echo "  # ---------------------------------------------------------------------------" >> crypto-config.yaml
	echo "  # Org$i: See "Org$i" for full specification" >> crypto-config.yaml
	echo "  # ---------------------------------------------------------------------------" >> crypto-config.yaml	
	echo "  - Name: Org$i" >> crypto-config.yaml
	echo "    Domain: org$i.example.com" >> crypto-config.yaml
	echo "    Template:" >> crypto-config.yaml
	echo "      Count: 2" >> crypto-config.yaml
	echo "    Users:" >> crypto-config.yaml
	echo "      Count: 1"   >> crypto-config.yaml
  done 
  # popd
else
  NOP=2
  # pushd ../sampleconfig/
  cp crypto-config.yaml.orig crypto-config.yaml 
  echo "Nothing to be done" $NOP
  # popd
fi
