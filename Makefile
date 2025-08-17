.PHONY: docs

docs:
	$(MAKE) -C modules docs
	$(MAKE) -C examples docs
