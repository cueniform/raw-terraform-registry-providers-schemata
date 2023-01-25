SHELL:=/bin/bash
CUE?=cue
default:

.PHONY: test
test:
	# Test tmp/terraform/provider.tf.json
	make PROVIDER=test_namespace/test_provider VERSION=1.2.3 tmp/terraform/provider.tf.json
	diff -u ./{test/,}tmp/terraform/provider.tf.json
	make clean
	# Test tmp/terraform/.terraform.lock.hcl
	make PROVIDER=test_namespace/test_provider VERSION=1.2.3 tmp/terraform/.terraform.lock.hcl
	diff -u ./{test/,}tmp/terraform/.terraform.lock.hcl
	make clean
	# Test tmp/terraform/.terraform/<some provider>
	make PROVIDER=hashicorp/null VERSION=3.2.1 tmp/terraform/.terraform/providers/registry.terraform.io/hashicorp/null/3.2.1/linux_amd64/
	sha256sum -c test/tmp/terraform/.terraform/providers/registry.terraform.io/hashicorp/null/3.2.1/linux_amd64/terraform-provider-null_v3.2.1_x5.SHA256SUM
	# Test tmp/schema.json
	make PROVIDER=hashicorp/null VERSION=3.2.1 tmp/schema.json
	diff -u ./{test/,}tmp/schema.json
	# Test tmp/schema.json.zstd
	make PROVIDER=hashicorp/null VERSION=3.2.1 tmp/schema.json.zstd
	diff -u ./{test/,}tmp/schema.json.zstd
	make clean

tmp/terraform/provider.tf.json: | check-input-variables
	$(CUE) export cueniform.com/collector/lib/templates --force \
	  --inject provider_version="$(VERSION)" --inject provider_identifier="$(PROVIDER)" \
	  -e provider_tf.out --outfile "$@"
tmp/terraform/.terraform.lock.hcl: | check-input-variables
	$(CUE) export cueniform.com/collector/lib/templates --force \
	  --inject provider_version="$(VERSION)" --inject provider_identifier="$(PROVIDER)" \
	  -e lockfile_hcl.out --outfile "$@" --out text
tmp/terraform/.terraform/providers/registry.terraform.io/$(PROVIDER)/$(VERSION)/linux_amd64/: tmp/terraform/provider.tf.json tmp/terraform/.terraform.lock.hcl
	terraform -chdir="tmp/terraform" init -lockfile=readonly -input=false -no-color
tmp/schema.json: tmp/terraform/.terraform/providers/registry.terraform.io/$(PROVIDER)/$(VERSION)/linux_amd64/
	terraform -chdir="tmp/terraform" providers schema -json >"$@"
tmp/schema.json.zstd: tmp/schema.json
	zstd --ultra -22 "$^" -o "$@" --force

.PHONY: check-input-variables
check-input-variables:
ifndef VERSION
	$(error VERSION is not set)
endif
ifndef PROVIDER
	$(error PROVIDER is not set)
endif

default:
	false
clean:
	rm -rvf $(CLEANABLE_FILES)

MAKEFLAGS+=--no-builtin-rules
MAKEFLAGS+=--no-builtin-variables
MAKEFLAGS+=--no-print-directory

CLEANABLE_FILES+=tmp/terraform/provider.tf.json
CLEANABLE_FILES+=tmp/terraform/.terraform.lock.hcl
CLEANABLE_FILES+=tmp/terraform/.terraform/
CLEANABLE_FILES+=tmp/schema.json
CLEANABLE_FILES+=tmp/schema.json.zstd
