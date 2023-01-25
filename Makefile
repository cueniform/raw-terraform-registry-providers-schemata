SHELL:=/bin/bash
CUE?=cue
default:

.PHONY: test
test:
	$(MAKE) PROVIDER=test_namespace/test_provider VERSION=1.2.3 tmp/terraform/provider.tf.json
	diff -u ./{test/,}tmp/terraform/provider.tf.json
	rm tmp/terraform/provider.tf.json

tmp/terraform/provider.tf.json:
	$(CUE) export cueniform.com/collector/lib/templates \
	  --inject provider_version="$(VERSION)" --inject provider_identifier="$(PROVIDER)" \
	  -e provider_tf.out --outfile "$@"

default:
	false
