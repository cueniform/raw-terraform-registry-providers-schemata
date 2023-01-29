default: # no-op default target, defined at end of file
THIS_MAKEFILE:=$(lastword $(MAKEFILE_LIST))
GOALS_WITHOUT_PARAMS:=clean test deps registry test-registry test-schema missing_schemas missing
TERRAFORM=terraform -chdir="build/terraform"
PROVIDER_SPACE_SEP_STRING=$(subst /, ,$(PROVIDER))
PROVIDER_VENDOR=$(word 1,$(PROVIDER_SPACE_SEP_STRING))
PROVIDER_NAME=$(word 2,$(PROVIDER_SPACE_SEP_STRING))
TARGET:=build/target
NON=| tr -d '\n'
.PHONY: FORCE

include Makefile.shared

#######################################################
### Test targets ######################################
#######################################################

.PHONY: test
test: deps test-schema test-registry
	$(MSG)
.PHONY: test-schema
test-schema:
	$(MSG)
	make -C test/one_provider_one_version check
	make -C test/one_provider_two_version check
.PHONY: test-registry
test-registry:
	$(MSG)
	make -C test/registry check

#######################################################
### Convenience shims #################################
#######################################################

.PHONY: missing_schemas
missing_schemas: COUNT?=10
missing_schemas: missing
	head -n $(COUNT) missing \
	| while read NAMESPACE TYPE VERSION; do \
	  $(MAKE) -f $(THIS_MAKEFILE) schema PROVIDER="$${NAMESPACE}/$${TYPE}" VERSION="$${VERSION}" ;\
	done

.PHONY: schema
schema: schemata/providers/$(PROVIDER)/$(VERSION).json.zstd
schema: schemata/providers/$(PROVIDER)/metadata/$(VERSION).v1meta.cue
	$(MSG)

#######################################################
### Top-level files we want to accumulate & commit ####
#######################################################

schemata/providers/$(PROVIDER)/$(VERSION).json.zstd: build/schema.json.zstd | schemata/providers/$(PROVIDER)/
	$(MSG)
	cp --update --no-target-directory --verbose "$^" "$@"

schemata/providers/$(PROVIDER)/metadata/$(VERSION).v1meta.cue: build/meta/ | schemata/providers/$(PROVIDER)/metadata/
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

schemata/providers/$(PROVIDER)/metadata: schemata/providers/$(PROVIDER)/metadata/metadata.cue
schemata/providers/$(PROVIDER)/metadata: schemata/providers/$(PROVIDER)/metadata/v1meta.cue

schemata/providers/$(PROVIDER)/metadata/metadata.cue: schemata/providers/$(PROVIDER)/metadata/
	$(MSG)
	$(CUE) export cueniform.com/collector/lib/templates/metadata --force \
	  --inject provider_identifier="$(PROVIDER)" \
	  -e package_file.out --outfile "$@" --out text

schemata/providers/$(PROVIDER)/metadata/v1meta.cue: schemata/providers/$(PROVIDER)/metadata/
	$(MSG)
	echo "package v1" >"$@"

#######################################################
### Interim schema files ##############################
#######################################################

build/schema.json.zstd: build/schema.json
	$(MSG)
	zstd --ultra -22 "$^" -o "$@" --force
build/schema.json: build/terraform/.terraform/ $(TARGET)
	$(MSG)
	$(TERRAFORM) providers schema -json >"$@"
build/terraform/.terraform/: build/terraform/.terraform/providers/registry.terraform.io/$(PROVIDER)/$(VERSION)/linux_amd64/terraform-provider-$(PROVIDER_NAME)_v$(VERSION)
build/terraform/.terraform/providers/registry.terraform.io/$(PROVIDER)/$(VERSION)/linux_amd64/terraform-provider-$(PROVIDER_NAME)_v$(VERSION): build/terraform/provider.tf.json build/terraform/.terraform.lock.hcl
	$(MSG)
	$(TERRAFORM) init -lockfile=readonly -input=false -no-color
	mv "$$(find "$(dir $@)" -executable -type f -ls | sort -nk7 | awk 'END{for (i=1; i<11; i++) $$i="";  gsub(/^[[:space:]]+|[[:space:]]+$$/,""); print}')" "$@" || touch "$@"
build/terraform/.terraform.lock.hcl: $(TARGET)
	$(MSG)
	$(CUE) export cueniform.com/collector/lib/templates --force \
	  --inject provider_version="$(VERSION)" --inject provider_identifier="$(PROVIDER)" \
	  -e lockfile_hcl.out --outfile "$@" --out text
build/terraform/provider.tf.json: $(TARGET)
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

build/meta/meta.terraform.json: $(TARGET)
	$(MSG)
	$(TERRAFORM) version -json >"$@"
.PHONY: build/meta/meta.timestamp.txt
build/meta/meta.timestamp.txt:
	$(MSG)
	date -uIs $(NON) >"$@"
build/meta/meta.provider_version.txt: $(TARGET)
	$(MSG)
	echo "$(VERSION)" $(NON) >"$@"
build/meta/meta.provider_identifier.txt: $(TARGET)
	$(MSG)
	echo "$(PROVIDER)" $(NON) >"$@"
build/meta/meta.schema_compressed_format.txt: $(MAKEFILE_LIST)
	$(MSG)
	echo "zstd" $(NON) >"$@"
build/meta/meta.schema_raw_format.txt: $(MAKEFILE_LIST)
	$(MSG)
	echo "json" $(NON) >"$@"
build/meta/meta.schema_raw_filename.txt: $(TARGET)
	$(MSG)
	echo "$(VERSION).json" $(NON) >"$@"
build/meta/meta.schema_compressed_filename.txt: $(TARGET)
	$(MSG)
	echo "$(VERSION).json.zstd" $(NON) >"$@"

build/meta/meta.schema_raw_size_bytes.txt:        build/schema.json
build/meta/meta.schema_raw_sha512.txt:            build/schema.json
build/meta/meta.schema_compressed_size_bytes.txt: build/schema.json.zstd
build/meta/meta.schema_compressed_sha512.txt:     build/schema.json.zstd

#######################################################
### Pattern target ####################################
#######################################################

build/meta/meta.%_size_bytes.txt:
	$(MSG)
	stat --printf %s "$<" $(NON) >"$@"
build/meta/meta.%_sha512.txt:
	$(MSG)
	sha512sum "$^" | cut -f1 -d ' ' $(NON) >"$@"
build/meta/meta.env_%.txt: FORCE
	$(MSG)
	{ printenv "$*" || true; } $(NON) >"$@"

# Directories without explicit recipes
%/:
	$(MSG)
	mkdir -p "$@"
	touch "$@"

#######################################################
### Sub-make targets ##################################
#######################################################

.PHONY: registry
registry: REGISTRY_TARGET?=all
registry:
	$(MSG)
	make -C registry $(REGISTRY_TARGET)

#######################################################
### Asorted misc targets ##############################
#######################################################

missing: SORT?=shuf
missing:
	$(MSG)
	$(CUE) export cueniform.com/collector/schemata:missing \
	  -e text --out text \
	| $(SORT) \
	>"$@"

ifeq (,$(filter $(GOALS_WITHOUT_PARAMS),$(MAKECMDGOALS)))
$(THIS_MAKEFILE): update_target
endif

.PHONY: update_target
update_target: | check_params
	$(MSG)
	! fgrep -qx $(PROVIDER):$(VERSION) $(TARGET) \
	&& echo $(PROVIDER):$(VERSION) >$(TARGET)

.PHONY: deps
.SILENT: deps
deps:
	$(MSG)
	$(CUE)       version
	$(TERRAFORM) version
	sha512sum  --version
	zstd       --version

.PHONY: check_params
check_params:
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
CLEANABLE_FILES+=build/target
clean:
	$(MSG)
	rm -rvf $(CLEANABLE_FILES)
default:
	$(MSG)
	false

MAKEFLAGS+=--no-builtin-rules
MAKEFLAGS+=--no-builtin-variables
MAKEFLAGS+=--no-print-directory
