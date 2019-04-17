#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

# set filename $argv[1]
secretname=$1
envname=$2
note_name=$secretname.$envname.secret
# echo $filename | awk -F'[.]' '{print $1}' | set secretname 

lpass status -q > /dev/null
if [ $? -ne 0 ]
then
  echo -e "${RED}LastPass not logged in.${NC}"
  exit 1
fi

# lpass show -c $secretname.$envname.secret > /dev/null

# lpass show --notes example.dev.secret > /dev/null
echo "Looking for note: $note_name"
lpass show --notes "$note_name" > /dev/null

if [ $? -ne 0 ]
  then
  echo -e "${RED}Error retrieving values from LastPass.${NC}"
  echo "Please make sure secret is stored in format of <secret_name>.<env>.secret inside of LastPass (found $note_name)."
  exit 1
fi


echo "Note '$note_name' found. Applying secret."
lpass show --notes $note_name | docker secret create $secretname -

if [ $? -ne 0 ]
then
  # -- Future Optimization --
  # if the secret already exists, update it?
  # docker secret ls --format "{{lower .Name}}"

  echo "Secret '$secretname' could not be applied. Make sure secret doesn't already exist."
fi
