include ../make/defaults.mk

export DELAY?=0
export RUNNING_IN_TEST=true

.PHONY: test
test: test-generate-desiderata-from-provider-list

generate-desiderata-from-provider-list: FORCE
	# $(TESTMSG)
	$(MAKE) -C "$@" desiderata/
	$(MAKE) -C "$@" check_clean_working_tree

test-%:
	$(MAKE) clean-$(*)
	$(MAKE) $(*)
	$(MAKE) clean-$(*)

clean-%: FORCE
	$(MAKE) -C "$(*)" clean
