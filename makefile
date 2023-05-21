plan:
	- terraform plan -var-file="./environments/central.tfvars" 

apply:
	- terraform apply -var-file="./environments/central.tfvars" -auto-approve