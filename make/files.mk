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
	| awk --file=make/priorities.awk \
	| sort -rk3 \
	>"$@"
