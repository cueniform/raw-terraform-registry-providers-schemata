SHELL:=/bin/bash
CUE?=cue
default:

.PHONY: test
test:
	# Test tmp/terraform/provider.tf.json
	$(MAKE) PROVIDER=test_namespace/test_provider VERSION=1.2.3 tmp/terraform/provider.tf.json
	diff -u ./{test/,}tmp/terraform/provider.tf.json
	rm tmp/terraform/provider.tf.json
	# Test tmp/terraform/.terraform.lock.hcl
	$(MAKE) PROVIDER=test_namespace/test_provider VERSION=1.2.3 tmp/terraform/.terraform.lock.hcl
	diff -u ./{test/,}tmp/terraform/.terraform.lock.hcl
	rm tmp/terraform/.terraform.lock.hcl

tmp/terraform/provider.tf.json:
	$(CUE) export cueniform.com/collector/lib/templates \
	  --inject provider_version="$(VERSION)" --inject provider_identifier="$(PROVIDER)" \
	  -e provider_tf.out --outfile "$@"

tmp/terraform/.terraform.lock.hcl:
	$(CUE) export cueniform.com/collector/lib/templates \
	  --inject provider_version="$(VERSION)" --inject provider_identifier="$(PROVIDER)" \
	  -e lockfile_hcl.out --outfile "$@" --out text

default:
	false
