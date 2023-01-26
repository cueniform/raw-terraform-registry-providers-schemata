include ../../Makefile

MAKE_HC_NULL=make VERSION=3.2.1 PROVIDER=hashicorp/null

.PHONY: check
check: check_provider_tf_json
check: check_terraform_lock_hcl

.PHONY: check_provider_tf_json
check_provider_tf_json: 
	rm build/terraform/provider.tf.json
	$(MAKE_HC_NULL) build/terraform/provider.tf.json
	git diff --exit-code .

.PHONY: check_terraform_lock_hcl
check_terraform_lock_hcl:
	rm build/terraform/.terraform.lock.hcl
	$(MAKE_HC_NULL) build/terraform/.terraform.lock.hcl
	git diff --exit-code .
