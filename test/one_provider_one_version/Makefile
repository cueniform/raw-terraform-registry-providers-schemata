include ../Makefile.shared

define ASSERT_AND_CLEAN
  git diff --exit-code ./
  git clean -X ./ --force
  git restore ./build/
endef

.PHONY: FORCE
export TF_PLUGIN_CACHE_DIR?=$(HOME)/.terraform-plugin-cache-dir/
MAKE_HC_NULL=make -f ../../Makefile VERSION=3.2.1 PROVIDER=hashicorp/null
SHELL:=/bin/bash -euo pipefail

.PHONY: check
check: | $(TF_PLUGIN_CACHE_DIR)
check: check_provider_tf_json
check: check_terraform_lock_hcl
check: check_hashicorp_null_plugin_binary
check: check_schema
check: check_filing_cabinet_schema
check: check_meta_build
check: check_meta_cue


$(TF_PLUGIN_CACHE_DIR):
	$(TESTMSG)
	mkdir -p "$@"

.PHONY: check_provider_tf_json
check_provider_tf_json:
	$(TESTMSG)
	rm build/terraform/provider.tf.json
	$(MAKE_HC_NULL) build/terraform/provider.tf.json
	$(ASSERT_AND_CLEAN)

.PHONY: check_terraform_lock_hcl
check_terraform_lock_hcl:
	$(TESTMSG)
	rm build/terraform/.terraform.lock.hcl
	$(MAKE_HC_NULL) build/terraform/.terraform.lock.hcl
	$(ASSERT_AND_CLEAN)

.PHONY: check_hashicorp_null_plugin_binary
check_hashicorp_null_plugin_binary: TARGET=build/terraform/.terraform
check_hashicorp_null_plugin_binary: FILE=$(TARGET)/providers/registry.terraform.io/hashicorp/null/3.2.1/linux_amd64/terraform-provider-null_v3.2.1
check_hashicorp_null_plugin_binary:
	$(TESTMSG)
	rm checksums
	$(MAKE_HC_NULL) $(TARGET)/
	sha512sum $(FILE) >checksums
	$(ASSERT_AND_CLEAN)

.PHONY: check_schema
check_schema:
	$(TESTMSG)
	rm build/schema.json
	$(MAKE_HC_NULL) build/schema.json.zstd
	zstd -dcf build/schema.json.zstd >build/schema.json
	$(ASSERT_AND_CLEAN)

.PHONY: check_filing_cabinet_schema
check_filing_cabinet_schema:
	$(TESTMSG)
	rm build/schema.json
	$(MAKE_HC_NULL) schemata/providers/hashicorp/null/3.2.1.json.zstd
	zstd -dcf schemata/providers/hashicorp/null/3.2.1.json.zstd >build/schema.json
	$(ASSERT_AND_CLEAN)

.PHONY: export_github_envvars
export_github_envvars: FORCE
	$(TESTMSG)
	$(eval export GITHUB_SHA=GITHUB_SHA-is-set-in-test-makefile)
	$(eval export GITHUB_WORKFLOW_SHA=GITHUB_WORKFLOW_SHA-is-set-in-test-makefile)
	$(eval unexport GITHUB_WORKFLOW_REF)

.PHONY: check_meta_build
check_meta_build: export_github_envvars
	$(TESTMSG)
	rm build/meta/*
	$(MAKE_HC_NULL) build/meta/
	$(ASSERT_AND_CLEAN)

.PHONY: check_meta_cue
check_meta_cue: export_github_envvars
	$(TESTMSG)
	rm build/meta/*
	$(MAKE_HC_NULL) schemata/providers/hashicorp/null/metadata/{3.2.1.v1meta.cue,metadata.cue}
	$(CUE) vet -c cueniform.com/collector/schemata/providers/hashicorp/null/metadata
	$(CUE) vet -c cueniform.com/collector/schemata/providers/hashicorp/null/metadata:v1
	$(ASSERT_AND_CLEAN)

.PHONY: check_make_schema
check_make_schema: export_github_envvars
	$(TESTMSG)
	git ls-tree --name-only -r HEAD build  | xargs -n1 rm -fv
	$(MAKE_HC_NULL) schema
	$(CUE) vet -c cueniform.com/collector/schemata/providers/hashicorp/null/metadata
	$(CUE) vet -c cueniform.com/collector/schemata/providers/hashicorp/null/metadata:v1
	$(ASSERT_AND_CLEAN)
