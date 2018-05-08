#!/bin/bash
#set -x

NOP=$1

if [ $NOP -gt 2 ]
then
  echo "Updating Crypto Material" $NOP
else
  NOP=2
  echo "Nothing to be done" $NOP
fi
