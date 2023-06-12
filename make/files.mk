# Only real file targets live in here,
# so it can be included from test dirs

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
	| awk ' \
	    BEGIN{prev=""; pri=0} \
	    {cur=$$1} \
	    prev==cur{pri++} \
	    prev!=cur{prev=cur; pri=0} \
	    {print $$0, pri}' \
	| sort -rk3 \
	>"$@"
