PROJECTS := $(dir $(wildcard */README.md))

docs: $(PROJECTS) gcp-recursive databricks-recursive

$(PROJECTS):
	$(MAKE) -C $@ docs

gcp-recursive:
	$(MAKE) -C gcp docs

databricks-recursive:
	$(MAKE) -C databricks docs

.PHONY: $(PROJECTS) docs gcp-recursive databricks-recursive
