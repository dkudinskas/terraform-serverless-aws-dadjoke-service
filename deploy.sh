#!/usr/bin/env bash
set -x

function get_config_var() {
  value=$(grep -oP "(?<=\"$1\": \")[^\"]*" config.json)
  echo "-var $1=$value"
}

AWS_SERVICE_NAME=$(get_config_var "app_name")
AWS_SERVICE_VERSION=$(get_config_var "app_version")
AWS_REGION=$(get_config_var "aws_region")
AWS_ACCOUNT_ID=$(get_config_var "aws_account_id")
AWS_DDB_TABLE=$(get_config_var "aws_ddb_table")

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
  deploy "terraform/state" "$AWS_REGION"
  deploy "terraform/database" "$AWS_REGION" "$AWS_DDB_TABLE"
  deploy "terraform/application" "$AWS_REGION" "$AWS_SERVICE_NAME" "$AWS_SERVICE_VERSION" "$AWS_ACCOUNT_ID" "$AWS_DDB_TABLE"
}

function destroy() {
  cd "$1" || exit 1
  terraform destroy ${@:2}
  [ $? -eq 0 ] && echo "Destroyed $1" || exit 1
  cd - || exit 1
}

function destroy_all() {
  destroy "terraform/application" "$AWS_REGION" "$AWS_SERVICE_NAME" "$AWS_SERVICE_VERSION" "$AWS_ACCOUNT_ID" "$AWS_DDB_TABLE"
  destroy "terraform/database" "$AWS_REGION" "$AWS_DDB_TABLE"
  destroy "terraform/state" "$AWS_REGION"
}

if [ ! -f "./config.json" ]
then
  echo Cannot find config file 'config.json'!
  exit
fi

COLUMNS=20
PS3='
<enter> - will print this menu again

What do you want to deploy? '

select opt in "State Bucket" "Database" "Service" "All" "Quit" "Destroy State Bucket" "Destroy Database" "Destroy Application" "Destroy All"
do
  case $opt in
    "State Bucket" )
      deploy "terraform/state" "$AWS_REGION"
      ;;
    "Database" )
      deploy "terraform/database" "$AWS_REGION" "$AWS_DDB_TABLE"
      ;;
    "Service" )
      deploy "terraform/application" "$AWS_REGION" "$AWS_SERVICE_NAME" "$AWS_SERVICE_VERSION" "$AWS_ACCOUNT_ID" "$AWS_DDB_TABLE"
      ;;
    "All" )
      deploy_all
      ;;
    "Destroy State Bucket" )
      destroy "terraform/state" "$AWS_REGION"
      ;;
    "Destroy Database" )
      destroy "terraform/database" "$AWS_REGION" "$AWS_DDB_TABLE"
      ;;
    "Destroy Application" )
      destroy "terraform/application" "$AWS_REGION" "$AWS_SERVICE_NAME" "$AWS_SERVICE_VERSION" "$AWS_ACCOUNT_ID" "$AWS_DDB_TABLE"
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
