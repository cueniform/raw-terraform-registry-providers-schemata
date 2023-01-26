include ../../Makefile

MAKE_HC_NULL=make VERSION=3.2.1 PROVIDER=hashicorp/null

define ASSERT_AND_CLEAN
  git diff --exit-code ./
  git clean -X ./ --force
  git restore ./build/
endef

.PHONY: check
check: check_provider_tf_json
check: check_terraform_lock_hcl
check: check_hashicorp_null_plugin_binary

.PHONY: check_provider_tf_json
check_provider_tf_json: 
	rm build/terraform/provider.tf.json
	$(MAKE_HC_NULL) build/terraform/provider.tf.json
	$(ASSERT_AND_CLEAN)

.PHONY: check_terraform_lock_hcl
check_terraform_lock_hcl:
	rm build/terraform/.terraform.lock.hcl
	$(MAKE_HC_NULL) build/terraform/.terraform.lock.hcl
	$(ASSERT_AND_CLEAN)

.PHONY: check_hashicorp_null_plugin_binary
check_hashicorp_null_plugin_binary: TARGET_MAKE=build/terraform/.terraform/providers/registry.terraform.io/hashicorp/null/3.2.1/linux_amd64
check_hashicorp_null_plugin_binary: TARGET_CHECK=$(TARGET_MAKE)/terraform-provider-null_v3.2.1_x5
check_hashicorp_null_plugin_binary:
	rm -rv $(TARGET_MAKE)/
	$(MAKE_HC_NULL) $(TARGET_MAKE)/
	sha512sum $(TARGET_CHECK) >$(TARGET_CHECK).sha512sum
	$(ASSERT_AND_CLEAN)
