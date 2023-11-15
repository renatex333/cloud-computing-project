#!/bin/bash
ROOT_PATH=$(git rev-parse --show-toplevel)
PROJECT_PATH="$ROOT_PATH/project"

cd $PROJECT_PATH
terraform destroy -auto-approve 
