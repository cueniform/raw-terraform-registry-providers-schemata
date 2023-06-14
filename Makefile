include make/defaults.mk
include make/files.mk

DELAY?=5
GIT_PATH=.

test quick: FORCE
	$(TESTMSG)
	$(MAKE) -C test/ "$@"

clean: FORCE
	$(MSG)
	git clean -n -dfX $(GIT_PATH)

desiderata/: FORCE
	$(MSG)
	./bin/generate-desiderata-for-all-providers.sh $(DELAY)

check_clean_working_tree: FORCE
	$(TESTMSG)
	test -z "$$(git status --porcelain $(GIT_PATH))" || { git status $(GIT_PATH); git diff $(GIT_PATH); false; }
