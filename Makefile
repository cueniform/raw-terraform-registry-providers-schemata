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

.INTERMEDIATE: schemata/empty.cue
schemata/empty.cue:
	# $@
	@echo "package schemata" >"$@"

.PHONY .INTERMEDIATE: schemata.txt
schemata.txt: schemata/empty.cue
	# $@
	@cue export ./schemata \
	  -e 'inventory.text' \
	  --out text \
	>"$@"

.INTERMEDIATE: delta.txt
delta.txt: schemata.txt $(wildcard desiderata/*.txt)
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
