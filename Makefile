SHELL:=/bin/bash
CUE?=cue
CLEANABLE_FILES=tmp/terraform/provider.tf.json tmp/terraform/.terraform.lock.hcl tmp/terraform/.terraform/

default:
clean:
	rm -rvf $(CLEANABLE_FILES)

.PHONY: test
test:
	# Test tmp/terraform/provider.tf.json
	$(MAKE) PROVIDER=test_namespace/test_provider VERSION=1.2.3 tmp/terraform/provider.tf.json
	diff -u ./{test/,}tmp/terraform/provider.tf.json
	$(MAKE) clean
	# Test tmp/terraform/.terraform.lock.hcl
	$(MAKE) PROVIDER=test_namespace/test_provider VERSION=1.2.3 tmp/terraform/.terraform.lock.hcl
	diff -u ./{test/,}tmp/terraform/.terraform.lock.hcl
	$(MAKE) clean
	# Test tmp/terraform/.terraform/<some provider>
	$(MAKE) PROVIDER=hashicorp/null VERSION=3.2.1 tmp/terraform/.terraform/providers/registry.terraform.io/hashicorp/null/3.2.1/linux_amd64/
	sha256sum -c test/tmp/terraform/.terraform/providers/registry.terraform.io/hashicorp/null/3.2.1/linux_amd64/terraform-provider-null_v3.2.1_x5.SHA256SUM
	$(MAKE) clean

tmp/terraform/provider.tf.json:
	$(CUE) export cueniform.com/collector/lib/templates \
	  --inject provider_version="$(VERSION)" --inject provider_identifier="$(PROVIDER)" \
	  -e provider_tf.out --outfile "$@"
tmp/terraform/.terraform.lock.hcl:
	$(CUE) export cueniform.com/collector/lib/templates \
	  --inject provider_version="$(VERSION)" --inject provider_identifier="$(PROVIDER)" \
	  -e lockfile_hcl.out --outfile "$@" --out text
tmp/terraform/.terraform/providers/registry.terraform.io/$(PROVIDER)/$(VERSION)/linux_amd64/: tmp/terraform/provider.tf.json tmp/terraform/.terraform.lock.hcl
	terraform -chdir="tmp/terraform" init -lockfile=readonly -input=false -no-color

default:
	false
