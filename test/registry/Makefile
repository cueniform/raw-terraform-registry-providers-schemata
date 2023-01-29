default:
	false

include Makefile.PROVIDERS

.PHONY: check
check:
	make -f ../../registry/Makefile all
	cue vet -c $(PROVIDERS) # FIXME: add some static assertions
	rm $(PROVIDERS)
	make -f ../../registry/Makefile bucket-4
	cue vet -c $(PROVIDERS) # FIXME: add some static assertions
	rm $(PROVIDERS)
