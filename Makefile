.PHONY: docs fmt

docs:
	$(MAKE) -C modules docs
	$(MAKE) -C examples docs

fmt:
	terraform fmt -recursive

fmt-check:
	terraform fmt -recursive -check
