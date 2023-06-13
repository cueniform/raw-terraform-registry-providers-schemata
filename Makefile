include make/defaults.mk
include make/files.mk

.PHONY: test quick
test quick:
	$(TESTMSG)
	$(MAKE) -C test/ "$@"

.PHONY: clean
clean:
	$(MSG)
	$(MAKE) -C test/ clean
	rm -vf schemata/empty.cue schemata.txt delta.txt priorities.txt
