default: # no-op default target, defined at end of file

SHELL:=/bin/bash -euo pipefail

.PHONY: test
test:
	$(TESTMSG)
	$(MAKE) -C test/ test

.PHONY: clean
clean:
	$(MSG)
	$(MAKE) -C test/ clean

default:
	$(MSG)
	false

MAKEFLAGS+=--no-builtin-rules
MAKEFLAGS+=--no-builtin-variables
MAKEFLAGS+=--no-print-directory

BOLD_RED!=echo -e "\e[31;1m"
BOLD_GREEN!=echo -e "\e[32;1m"
BOLD_YELLOW!=echo -e "\e[33;1m"
COLOUR_RESET!=echo -e "\e[0m"

define TESTMSG
#
# $(BOLD_YELLOW)Testing: $@$(COLOUR_RESET)
#
endef

define MSG
#
# $(BOLD_GREEN)Making: $@$(COLOUR_RESET)
#
endef
