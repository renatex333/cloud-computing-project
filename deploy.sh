#!/bin/bash
ROOT_PATH=$(git rev-parse --show-toplevel)
PROJECT_PATH="$ROOT_PATH/project"

DEFAULT_DB_USERNAME="modusponens"
read -p "Database Username [$DEFAULT_DB_USERNAME]: " DB_USERNAME

# If no username is entered, use a default value.
if [ -z "$DB_USERNAME" ]; then
    DB_USERNAME=$DEFAULT_DB_USERNAME
fi

# Generate a random password
DEFAULT_DB_PASSWORD=$(date +%s | sha256sum | base64 | head -c 32)
read -p "Database Password [$DEFAULT_DB_PASSWORD]: " DB_PASSWORD

# If no password is entered, use the generated value.
if [ -z "$DB_PASSWORD" ]; then
    DB_PASSWORD=$DEFAULT_DB_PASSWORD
fi

echo "Your username is $DB_USERNAME and your password is $DB_PASSWORD"
echo "db_username = \"$DB_USERNAME\"" > "$PROJECT_PATH/terraform.tfvars"
echo "db_password = \"$DB_PASSWORD\"" >> "$PROJECT_PATH/terraform.tfvars"

cd $PROJECT_PATH
terraform init
terraform plan -var-file="terraform.tfvars" -out tplan
terraform apply -auto-approve tplan