#!/usr/bin/env bash
# uncomment for verbose output
#set -x

function get_tf_var() {
  value=$(grep -oP "(?<=\"$1\": \")[^\"]*" config.json)
  if [ -z "$value" ]
  then
    exit 22
  else
   echo "-var $1=$value"
  fi;
}

# lets make the parameters in config.json mandatory
if [ ! -f "./config.json" ]; then echo "Cannot find config file 'config.json'!"; exit 2; fi

VAR_SERVICE_NAME=$(get_tf_var "app_name" )
if [ $? -eq 22 ]; then echo "No app name in config file!"; exit 1; fi
VAR_SERVICE_VERSION=$(get_tf_var "app_version" )
if [ $? -eq 22 ]; then echo "No app version in config file!"; exit 1; fi
VAR_REGION=$(get_tf_var "aws_region" )
if [ $? -eq 22 ]; then echo "No aws region in config file!"; exit 1; fi
VAR_ACCOUNT_ID=$(get_tf_var "aws_account_id")
if [ $? -eq 22 ]; then echo "No aws account id in config file!"; exit 1; fi
VAR_DDB_TABLE=$(get_tf_var "aws_ddb_table")
if [ $? -eq 22 ]; then echo "No aws dynamo db table name id in config file!"; exit 1; fi


function deploy() {
  echo "Checking Terraform in $1..."
  cd "$1" || exit 1
  [ ! -f ".terraform.lock.hcl" ] && terraform init

  terraform validate
  [ $? -eq 0 ] && echo "Terraform configuration is valid in $1!" || exit 1

  echo "Applying terraform in $1"
  terraform apply ${@:2}
  [ $? -eq 0 ]  || exit 1

  cd - || exit 1
}

function deploy_all() {
  deploy "terraform/state" "$VAR_REGION" "$VAR_SERVICE_NAME"
  deploy "terraform/database" "$VAR_REGION" "$VAR_DDB_TABLE" "$VAR_SERVICE_NAME"
  deploy "terraform/application" "$VAR_REGION" "$VAR_SERVICE_NAME" "$VAR_SERVICE_VERSION" "$VAR_ACCOUNT_ID" "$VAR_DDB_TABLE"
}

function zip_lambda() {
  app=$(grep -oP "(?<=\"app_name\": \")[^\"]*" config.json)
  cd lambda/"$app" && zip "$app".zip main.js && cd -
}

function destroy() {
  cd "$1" || exit 1
  terraform destroy ${@:2}
  [ $? -eq 0 ] && echo "Destroyed $1" || exit 1
  cd - || exit 1
}

function destroy_all() {
  destroy "terraform/application" "$VAR_REGION" "$VAR_SERVICE_NAME" "$VAR_SERVICE_VERSION" "$VAR_ACCOUNT_ID" "$VAR_DDB_TABLE"
  destroy "terraform/database" "$VAR_REGION" "$VAR_DDB_TABLE" "$VAR_SERVICE_NAME"
  destroy "terraform/state" "$VAR_REGION" "$VAR_SERVICE_NAME"
}

COLUMNS=20
PS3='
<enter> - will print this menu again

What do you want to deploy? '

select opt in "State Bucket" "Database" "Application" "All" "Destroy State Bucket" "Destroy Database" "Destroy Application" "Destroy All" "Quit"
do
  case $opt in
    "State Bucket" )
      deploy "terraform/state" "$VAR_REGION" "$VAR_SERVICE_NAME"
      ;;
    "Database" )
      deploy "terraform/database" "$VAR_REGION" "$VAR_DDB_TABLE" "$VAR_SERVICE_NAME"
      ;;
    "Application" )
      zip_lambda
      deploy "terraform/application" "$VAR_REGION" "$VAR_SERVICE_NAME" "$VAR_SERVICE_VERSION" "$VAR_ACCOUNT_ID" "$VAR_DDB_TABLE"
      ;;
    "All" )
      deploy_all
      ;;
    "Destroy State Bucket" )
      destroy "terraform/state" "$VAR_REGION" "$VAR_SERVICE_NAME"
      ;;
    "Destroy Database" )
      destroy "terraform/database" "$VAR_REGION" "$VAR_DDB_TABLE" "$VAR_SERVICE_NAME"
      ;;
    "Destroy Application" )
      destroy "terraform/application" "$VAR_REGION" "$VAR_SERVICE_NAME" "$VAR_SERVICE_VERSION" "$VAR_ACCOUNT_ID" "$VAR_DDB_TABLE"
      ;;
    "Destroy All" )
      destroy_all
      ;;
    "Quit" )
      break;
      ;;
    *)
      echo "Invalid option in $opt"; continue;;
  esac
done
