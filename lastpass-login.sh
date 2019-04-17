#!/bin/bash

lastpass_login () {
  lpass status -q > /dev/null

  if [ $? -ne 0 ]
  then
    echo "Start LastPass login"
    
    if [ $is_swarm = "true" ]
    then
      echo "Secret 'lastpass_username' and 'lastpass_password' used."
      lastpass_username=( $(cat /run/secrets/lastpass_username) )
      lastpass_password=( $(cat /run/secrets/lastpass_password) )
    else
      echo "LastPass credentials required:"
      read -p "LastPass Username> " lastpass_username
      read -s -p "LastPass Password> " lastpass_password
    fi
    
    echo $lastpass_password | lpass login --trust $lastpass_username
    if [ $? -ne 0 ]
    then
      echo "Unable to authenticate with LastPass!"
      exit 1
    fi
    echo "Successfully logged in."
  fi
  echo "Starting LastPass sync..."
  lpass sync
  if [ $? -ne 0 ]
  then
    echo "Error syncing with LastPass!"
    exit 1
  fi
  echo "Sync complete."; 
}

lastpass_login
