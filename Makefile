default: # no-op default target, defined at end of file
SHELL:=/bin/bash -euo pipefail
CUE?=cue
TERRAFORM=terraform -chdir="build/terraform"
PROVIDER_SPACE_SEP_STRING=$(subst /, ,$(PROVIDER))
PROVIDER_NAME=$(word 2,$(PROVIDER_SPACE_SEP_STRING))
NON=| tr -d '\n'
.PHONY: force

BOLD_RED:=$(shell echo -e "\e[31;1m")
BOLD_GREEN:=$(shell echo -e "\e[32;1m")
BOLD_YELLOW:=$(shell echo -e "\e[33;1m")
COLOUR_RESET:=$(shell echo -e "\e[0m")

define MSG
#
# $(BOLD_GREEN)Making: $@$(COLOUR_RESET)
#
endef

#######################################################
### Convenience shims #################################
#######################################################

.PHONY: all
all: | check_input_variables
all: schemata/providers/$(PROVIDER)/$(VERSION).json.zstd
all: schemata/providers/$(PROVIDER)/metadata/$(VERSION).v1meta.cue
all: schemata/providers/$(PROVIDER)/metadata/metadata.cue
	$(MSG)

#######################################################
### Top-level files we want to accumulate & commit ####
#######################################################

schemata/providers/$(PROVIDER)/$(VERSION).json.zstd: build/schema.json.zstd | check_input_variables
	$(MSG)
	mkdir -p "$(dir $@)"
	cp --update --no-target-directory --verbose "$^" "$@"

schemata/providers/$(PROVIDER)/metadata/$(VERSION).v1meta.cue: build/meta/ | check_input_variables schemata/providers/$(PROVIDER)/metadata/metadata.cue
	$(MSG)
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
	$(MSG)
	mkdir -p "$(dir $@)"
	$(CUE) export cueniform.com/collector/lib/templates/metadata --force \
	  --inject provider_identifier="$(PROVIDER)" \
	  -e package_file.out --outfile "$@" --out text

#######################################################
### Interim schema files ##############################
#######################################################

build/schema.json.zstd: build/schema.json
	$(MSG)
	zstd --ultra -22 "$^" -o "$@" --force
build/schema.json: build/terraform/.terraform/
	$(MSG)
	$(TERRAFORM) providers schema -json >"$@"
build/terraform/.terraform/: build/terraform/.terraform/providers/registry.terraform.io/$(PROVIDER)/$(VERSION)/linux_amd64/terraform-provider-$(PROVIDER_NAME)_v$(VERSION)
build/terraform/.terraform/providers/registry.terraform.io/$(PROVIDER)/$(VERSION)/linux_amd64/terraform-provider-$(PROVIDER_NAME)_v$(VERSION): build/terraform/provider.tf.json build/terraform/.terraform.lock.hcl | check_input_variables
	$(MSG)
	$(TERRAFORM) init -lockfile=readonly -input=false -no-color
	mv "$$(find "$(dir $@)" -executable -type f -ls | sort -nk7 | awk 'END{for (i=1; i<11; i++) $$i="";  gsub(/^[[:space:]]+|[[:space:]]+$$/,""); print}')" "$@"
build/terraform/.terraform.lock.hcl: | check_input_variables
	$(MSG)
	$(CUE) export cueniform.com/collector/lib/templates --force \
	  --inject provider_version="$(VERSION)" --inject provider_identifier="$(PROVIDER)" \
	  -e lockfile_hcl.out --outfile "$@" --out text
build/terraform/provider.tf.json: | check_input_variables
	$(MSG)
	$(CUE) export cueniform.com/collector/lib/templates --force \
	  --inject provider_version="$(VERSION)" --inject provider_identifier="$(PROVIDER)" \
	  -e provider_tf.out --outfile "$@"

#######################################################
### Interim metadata files ############################
#######################################################

build/meta/: build/meta/meta.provider_version.txt
build/meta/: build/meta/meta.provider_identifier.txt
build/meta/: | build/meta/meta.timestamp.txt
build/meta/: build/meta/meta.schema_raw_filename.txt
build/meta/: build/meta/meta.schema_raw_format.txt
build/meta/: build/meta/meta.schema_raw_size_bytes.txt
build/meta/: build/meta/meta.schema_raw_sha512.txt
build/meta/: build/meta/meta.schema_compressed_filename.txt
build/meta/: build/meta/meta.schema_compressed_format.txt
build/meta/: build/meta/meta.schema_compressed_size_bytes.txt
build/meta/: build/meta/meta.schema_compressed_sha512.txt
build/meta/: build/meta/meta.terraform.json
build/meta/: | build/meta/meta.env_GITHUB_SHA.txt
build/meta/: | build/meta/meta.env_GITHUB_WORKFLOW_SHA.txt
build/meta/: | build/meta/meta.env_GITHUB_WORKFLOW_REF.txt

build/meta/meta.terraform.json: build/schema.json
	$(MSG)
	$(TERRAFORM) version -json >"$@"
build/meta/meta.timestamp.txt: force
	$(MSG)
	date -uIs $(NON) >"$@"
build/meta/meta.provider_version.txt: build/schema.json | check_input_variables
	$(MSG)
	echo "$(VERSION)" $(NON) >"$@"
build/meta/meta.provider_identifier.txt: build/schema.json | check_input_variables
	$(MSG)
	echo "$(PROVIDER)" $(NON) >"$@"
build/meta/meta.schema_compressed_format.txt: $(MAKEFILE_LIST)
	$(MSG)
	echo "zstd" $(NON) >"$@"
build/meta/meta.schema_raw_format.txt: $(MAKEFILE_LIST)
	$(MSG)
	echo "json" $(NON) >"$@"
build/meta/meta.schema_raw_filename.txt: build/schema.json | check_input_variables
	$(MSG)
	echo "$(VERSION).json" $(NON) >"$@"
build/meta/meta.schema_compressed_filename.txt: build/schema.json.zstd | check_input_variables
	$(MSG)
	echo "$(VERSION).json.zstd" $(NON) >"$@"

build/meta/meta.schema_raw_size_bytes.txt: build/schema.json
build/meta/meta.schema_compressed_size_bytes.txt: build/schema.json.zstd
build/meta/meta.schema_raw_sha512.txt: build/schema.json
build/meta/meta.schema_compressed_sha512.txt: build/schema.json.zstd

#######################################################
### Pattern target ####################################
#######################################################

build/meta/meta.%_size_bytes.txt:
	$(MSG)
	stat --printf %s "$<" $(NON) >"$@"
build/meta/meta.%_sha512.txt:
	$(MSG)
	sha512sum "$^" | cut -f1 -d ' ' $(NON) >"$@"
build/meta/meta.env_%.txt: force
	$(MSG)
	{ printenv "$*" || true; } $(NON) >"$@"

# Directories without explicit recipes
%/:
	$(MSG)
	touch "$@"

#######################################################
### Asorted misc targets ##############################
#######################################################

.PHONY: test
test:
	$(MSG)
	make -C test/scenario-1 check

.PHONY: check_input_variables
check_input_variables:
	$(MSG)
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
	$(MSG)
	rm -rvf $(CLEANABLE_FILES)
default:
	$(MSG)
	false

MAKEFLAGS+=--no-builtin-rules
MAKEFLAGS+=--no-builtin-variables
MAKEFLAGS+=--no-print-directory
