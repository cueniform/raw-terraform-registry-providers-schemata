include ../make/defaults.mk

export DELAY?=0
export RUNNING_IN_TEST:=true

DRUN=cd "$(@)" &&
TEST=$(DRUN) $(MAKE) --jobs=1
ASSERT_SCHEMATA=$(DRUN) cue export ./schemata | cue vet -c .:tests json: -

test: FORCE
test: test-generate-desiderata-from-provider-list
test: test-e2e-bootstrap

generate-desiderata-from-provider-list: FORCE
	# $(TESTMSG)
	$(DRUN) rm -f desiderata/*.txt
	$(TEST) desiderata/ check_clean_working_tree

e2e-bootstrap: FORCE
	$(TEST) desiderata/ check_clean_working_tree

	$(ASSERT_SCHEMATA) -d before.definition

	$(TEST) schemata/ check_clean_working_tree COUNT=2
	$(ASSERT_SCHEMATA) -d after_2_schemata_downloads.definition

	$(TEST) schemata/ check_clean_working_tree COUNT=2
	$(ASSERT_SCHEMATA) -d after_4_schemata_downloads.definition

	$(TEST) schemata/ check_clean_working_tree COUNT=2
	$(ASSERT_SCHEMATA) -d after_4_schemata_downloads.definition

test-%: FORCE
	$(MAKE) clean-$(*)
	$(MAKE) $(*)
	$(MAKE) clean-$(*)

clean-%: FORCE
	$(MAKE) -C "$(*)" clean
