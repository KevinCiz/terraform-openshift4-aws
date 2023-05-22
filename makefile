init-local:
	- terraform init -reconfigure -plugin-dir=/usr/local/bin/providers

init:
	- terraform init 

plan:
	- terraform plan -refresh=true -var-file="./environments/central.tfvars" 

apply:
	- terraform apply -var-file="./environments/central.tfvars" -auto-approve

destroy:
	- terraform destroy -var-file="./environments/central.tfvars" -auto-approve