#!/bin/bash

echo 'Start Secrets Process'

# Default to a 'dev' environment
envname=( $([ -z "$env" ] && echo "dev"  || echo $env) )

# Check to see if the secrets folder exists
ls /run/secrets 2> /dev/null
# If secrets folder doesn't exist, then set is_local to true
if [ $? -eq 0 ]
then
  is_swarm="true"
else 
  is_swarm="false"
fi

if [ $is_swarm = "true" ]
then
  echo "Secrets folder was found. Secret 'lastpass_username' and 'lastpass_password' will be used."
else
  echo "Secrets folder not found. LastPass credentials will be required."
fi

# Log into LasPass
source lastpass-login.sh

config_file="/config/$envname.json"

echo "Config file to be used: $config_file"

cat $config_file | jq -r .[] | 
while IFS= read -r secret; do
  echo "Start processing secret: $secret"
  source /apply-secret.sh $secret $envname
  echo "End processing secret: $secret"
done

echo 'End Secrets Process'
