default:
	false

.PHONY: check
check: PROVIDERS=provider.namespace.hashicorp.type.null.cue
check:
	make -f ../../registry/Makefile PROVIDERS=$(PROVIDERS) all
	cue vet -c $(PROVIDERS) # FIXME: add some static assertions
	rm $(PROVIDERS)
	make -f ../../registry/Makefile PROVIDERS=$(PROVIDERS) bucket-2
	cue vet -c $(PROVIDERS) # FIXME: add some static assertions
	rm $(PROVIDERS)
