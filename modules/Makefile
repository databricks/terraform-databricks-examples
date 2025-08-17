PROJECTS := $(dir $(wildcard */README.md))

docs: $(PROJECTS)

$(PROJECTS):
	$(MAKE) -C $@ docs

.PHONY: $(PROJECTS)
