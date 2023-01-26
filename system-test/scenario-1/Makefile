include ../../Makefile

MAKE_DUMMY=make VERSION=1.2.3 PROVIDER=dummy_namespace/dummy_provider
MAKE_HC_NULL=make VERSION=3.2.1 PROVIDER=hashicorp/null

.PHONY: check
check: check_provider_tf_json

.PHONY: check_provider_tf_json
check_provider_tf_json: 
	rm build/terraform/provider.tf.json
	$(MAKE_DUMMY) build/terraform/provider.tf.json
	git diff --exit-code .
