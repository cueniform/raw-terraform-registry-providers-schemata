include Makefile.shared

define ASSERT_AND_CLEAN
  git diff --exit-code ./
  git clean -X ./ --force
  git restore ./build/
endef

.PHONY: FORCE
export TF_PLUGIN_CACHE_DIR?=$(HOME)/.terraform-plugin-cache-dir/
MAKE_HC_NULL=make -f ../../Makefile PROVIDER=hashicorp/null

.PHONY: check
check: | $(TF_PLUGIN_CACHE_DIR)
check: check_sequential_invocations
check: check_missing_version

clean:
	$(TESTMSG)
	$(ASSERT_AND_CLEAN)
	make -f ../../Makefile clean
	#git restore .

$(TF_PLUGIN_CACHE_DIR):
	$(TESTMSG)
	mkdir -p "$@"

.PHONY: check_sequential_invocations
check_sequential_invocations: export GITHUB_SHA=GITHUB_SHA-is-set-in-test-makefile
check_sequential_invocations: export GITHUB_WORKFLOW_SHA=GITHUB_WORKFLOW_SHA-is-set-in-test-makefile
check_sequential_invocations: export GITHUB_WORKFLOW_REF=
check_sequential_invocations:
	$(TESTMSG)
	$(MAKE_HC_NULL) VERSION=3.2.0 schema
	$(MAKE_HC_NULL) VERSION=3.2.1 schema
	$(CUE) vet -c cueniform.com/collector/schemata/providers/hashicorp/null/metadata
	$(CUE) vet -c cueniform.com/collector/schemata/providers/hashicorp/null/metadata:v1
	$(ASSERT_AND_CLEAN)

check_missing_version: export GITHUB_SHA=GITHUB_SHA-is-set-in-test-makefile
check_missing_version: export GITHUB_WORKFLOW_SHA=GITHUB_WORKFLOW_SHA-is-set-in-test-makefile
check_missing_version: export GITHUB_WORKFLOW_REF=
check_missing_version:
	$(TESTMSG)
	$(MAKE_HC_NULL) VERSION=3.2.0 schema
	make -f ../../Makefile missing_schemas
	$(CUE) vet -c cueniform.com/collector/schemata/providers/hashicorp/null/metadata:v1
	$(CUE) vet -c cueniform.com/collector/schemata/providers/hashicorp/null/metadata
