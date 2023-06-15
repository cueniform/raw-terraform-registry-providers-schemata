include make/defaults.mk

DELAY?=5
COUNT?=20
GIT_PATH=.

test: FORCE
	$(TESTMSG)
	$(MAKE) --jobs --output-sync=target -C test/ test

clean: FORCE
	$(MSG)
	git clean -dfX $(GIT_PATH)

desiderata/: FORCE
	$(MSG)
	./bin/generate-desiderata-for-all-providers.sh $(DELAY)

schemata/: FORCE
	$(MSG)
	./bin/process-next-N-missing-provider-versions.sh $(COUNT) $(DELAY)

check_clean_working_tree: FORCE
	$(TESTMSG)
	test -z "$$(git status --porcelain $(GIT_PATH))" || { git status $(GIT_PATH); git diff $(GIT_PATH); false; }

schemata/empty.cue:
	# $@
	@echo "package schemata" >"$@"

schemata.txt: schemata/empty.cue
schemata.txt: $(wildcard schemata/*.metadata.cue)
schemata.txt: $(shell grep --files-with-matches '^package schemata$$' *.cue)
schemata.txt:
	# $@
	@cue export ./schemata \
	  -e 'inventory.text' \
	  --out text \
	>"$@"

delta.txt: schemata.txt
delta.txt: $(wildcard desiderata/*.txt)
delta.txt:
	# $@
	@cat desiderata/*.txt \
	| { grep \
	      --invert-match \
	      --line-regexp \
	      --fixed-strings \
	      --file=schemata.txt \
	    || true ; } \
	>"$@"

priorities.txt: delta.txt
	# $@
	@cat delta.txt \
	| sort -Vr \
	| awk --file=make/priorities.awk \
	| sort -rk3 \
	>"$@"
