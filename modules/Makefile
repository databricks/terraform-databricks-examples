PROJECTS := $(dir $(wildcard */README.md))

docs: $(PROJECTS) gcp-recursive

$(PROJECTS):
	$(MAKE) -C $@ docs

gcp-recursive:
	$(MAKE) -C gcp docs

.PHONY: $(PROJECTS) docs gcp-recursive
