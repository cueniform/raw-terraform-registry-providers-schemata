include make/defaults.mk
include make/files.mk

DELAY?=0

.PHONY: test
test: clean-1 test_e2e clean-2

.PHONY: quick
quick: clean-1
	./bin/generate-desiderata-for-all-providers.sh      0
	./bin/process-next-N-missing-provider-versions.sh 1 0

.PHONY: test_e2e
test_e2e:
	./bin/generate-desiderata-for-all-providers.sh      $(DELAY)
	./bin/process-next-N-missing-provider-versions.sh 5 $(DELAY)
	./bin/process-next-N-missing-provider-versions.sh 5 $(DELAY)
	./bin/process-next-N-missing-provider-versions.sh 5 $(DELAY)
	cue vet -c ./schemata/test:schemata
	# TODO: add a content check (clean working tree, etc)

.PHONY: clean
clean: clean-99

clean-%:
	rm -f schemata/registry.terraform.io_*.json.zst
	rm -f schemata/registry.terraform.io_*.metadata.cue
	rm -f desiderata/registry.terraform.io_*.txt
