#!/bin/bash

cd /envs/dev

terragrunt init
terragrunt apply

cd ../../global

terragrunt init
terragrunt plan -out=global_plan.tfplan
terragrunt apply -auto-approve global_plan.tfplan