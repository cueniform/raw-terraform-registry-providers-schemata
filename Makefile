default: # no-op default target, defined at end of file
SHELL:=/bin/bash
CUE?=cue
TERRAFORM=terraform -chdir="build/terraform"
PROVIDER_SPACE_SEP_STRING=$(subst /, ,$(PROVIDER))
PROVIDER_NAME=$(word 2,$(PROVIDER_SPACE_SEP_STRING))
NON=| tr -d '\n'

schemata/providers/$(PROVIDER)/metadata/$(VERSION).v1meta.cue: build/meta/ | check_input_variables schemata/providers/$(PROVIDER)/metadata/metadata.cue
	{ \
	  echo "package v1" ; \
	  $(CUE) export cueniform.com/collector/lib/templates/metadata:v1 -e metadata.out \
	  -l 'metadata:' -l 'input:' \
	  -l 'strings.Join(strings.Split(path.Base(filename),".")[1:strings.Count(path.Base(filename),".")],".")' \
	  --with-context build/meta/meta.* \
	  --out cue ; \
	} >"$@"
	cue fmt "$@"

schemata/providers/$(PROVIDER)/metadata/metadata.cue: | check_input_variables
	mkdir -p "$(dir $@)"
	$(CUE) export cueniform.com/collector/lib/templates/metadata --force \
	  --inject provider_identifier="$(PROVIDER)" \
	  -e package_file.out --outfile "$@" --out text

build/meta/: build/meta/meta.provider_version.txt
build/meta/: build/meta/meta.provider_identifier.txt
build/meta/: build/meta/meta.timestamp.txt
build/meta/: build/meta/meta.schema_raw_filename.txt
build/meta/: build/meta/meta.schema_raw_format.txt
build/meta/: build/meta/meta.schema_raw_size_bytes.txt
build/meta/: build/meta/meta.schema_raw_sha512.txt
build/meta/: build/meta/meta.schema_compressed_filename.txt
build/meta/: build/meta/meta.schema_compressed_format.txt
build/meta/: build/meta/meta.schema_compressed_size_bytes.txt
build/meta/: build/meta/meta.schema_compressed_sha512.txt
build/meta/: build/meta/meta.terraform.json
build/meta/: build/meta/meta.env_GITHUB_SHA.txt
build/meta/: build/meta/meta.env_GITHUB_WORKFLOW_SHA.txt
build/meta/: build/meta/meta.env_GITHUB_WORKFLOW_REF.txt

build/meta/meta.provider_version.txt: build/schema.json | check_input_variables
	echo "$(VERSION)" $(NON) >"$@"
build/meta/meta.provider_identifier.txt: build/schema.json | check_input_variables
	echo "$(PROVIDER)" $(NON) >"$@"
build/meta/meta.terraform.json: build/schema.json
	$(TERRAFORM) version -json >"$@"
build/meta/meta.timestamp.txt: force
	date -uIs $(NON) >"$@"
build/meta/meta.schema_raw_sha512.txt: build/schema.json
build/meta/meta.schema_compressed_sha512.txt: build/schema.json.zstd
build/meta/meta.%_sha512.txt:
	sha512sum "$^" | cut -f1 -d ' ' $(NON) >"$@"
build/meta/meta.schema_compressed_format.txt: force
	echo "zstd" $(NON) >"$@"
build/meta/meta.schema_raw_format.txt: force
	echo "json" $(NON) >"$@"
build/meta/meta.schema_raw_size_bytes.txt: build/schema.json
build/meta/meta.schema_compressed_size_bytes.txt: build/schema.json.zstd
build/meta/meta.%_size_bytes.txt:
	stat --printf %s "$<" $(NON) >"$@"
build/meta/meta.env_%.txt: force
	printenv "$*" $(NON) >"$@"
build/meta/meta.schema_raw_filename.txt: build/schema.json | check_input_variables
	echo "$(VERSION).json" $(NON) >"$@"
build/meta/meta.schema_compressed_filename.txt: build/schema.json.zstd | check_input_variables
	echo "$(VERSION).json.zstd" $(NON) >"$@"

.PHONY: force

schemata/providers/$(PROVIDER)/$(VERSION).json.zstd: build/schema.json.zstd | check_input_variables
	mkdir -p "$(dir $@)"
	mv --update --no-target-directory --verbose "$^" "$@"
build/schema.json.zstd: build/schema.json
	zstd --ultra -22 "$^" -o "$@" --force
build/schema.json: build/terraform/.terraform/
	$(TERRAFORM) providers schema -json >"$@"
build/terraform/.terraform/: build/terraform/.terraform/providers/registry.terraform.io/$(PROVIDER)/$(VERSION)/linux_amd64/terraform-provider-$(PROVIDER_NAME)_v$(VERSION)
build/terraform/.terraform/providers/registry.terraform.io/$(PROVIDER)/$(VERSION)/linux_amd64/terraform-provider-$(PROVIDER_NAME)_v$(VERSION): build/terraform/provider.tf.json build/terraform/.terraform.lock.hcl | check_input_variables
	$(TERRAFORM) init -lockfile=readonly -input=false -no-color
	mv "$$(find "$(dir $@)" -executable -type f -ls | sort -nk7 | awk 'END{for (i=1; i<11; i++) $$i="";  gsub(/^[[:space:]]+|[[:space:]]+$$/,""); print}')" "$@"
build/terraform/.terraform.lock.hcl: | check_input_variables
	$(CUE) export cueniform.com/collector/lib/templates --force \
	  --inject provider_version="$(VERSION)" --inject provider_identifier="$(PROVIDER)" \
	  -e lockfile_hcl.out --outfile "$@" --out text
build/terraform/provider.tf.json: | check_input_variables
	$(CUE) export cueniform.com/collector/lib/templates --force \
	  --inject provider_version="$(VERSION)" --inject provider_identifier="$(PROVIDER)" \
	  -e provider_tf.out --outfile "$@"

.PHONY: test
test:
	make -C test/scenario-1 check

.PHONY: check_input_variables
check_input_variables:
ifndef VERSION
	$(error VERSION is not set)
endif
ifndef PROVIDER
	$(error PROVIDER is not set)
endif

CLEANABLE_FILES+=build/terraform/provider.tf.json
CLEANABLE_FILES+=build/terraform/.terraform.lock.hcl
CLEANABLE_FILES+=build/terraform/.terraform/
CLEANABLE_FILES+=build/schema.json
CLEANABLE_FILES+=build/schema.json.zstd
CLEANABLE_FILES+=build/meta/*
clean:
	rm -rvf $(CLEANABLE_FILES)
default:
	false

MAKEFLAGS+=--no-builtin-rules
MAKEFLAGS+=--no-builtin-variables
MAKEFLAGS+=--no-print-directory
