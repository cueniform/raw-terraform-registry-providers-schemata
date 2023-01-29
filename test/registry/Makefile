default:
	false

.PHONY: check
check: PROVIDERS=provider.namespace.hashicorp.type.null.cue
check:
	make -f ../../registry/Makefile all PROVIDERS=$(PROVIDERS)
	cue vet -c $(PROVIDERS) # FIXME: add some static assertions
	rm $(PROVIDERS)
