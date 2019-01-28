include PACKAGE

DIST_BINARIES := \
  $(DIST_DIR)/module-source-converter

.PHONY:bootstrap
bootstrap:
	git submodule update --init

.PHONY: tenv
tenv: $(DIST_BINARIES)
	@mkdir -p "$(DIST_DIR)"
	scripts/get-terraform-environment.sh

.PHONY: shell
shell:
	scripts/shell

# Always force to invoke the commands. Go compiler will figure out the
# dependencies to source files and do incremental build accordingly.
# TODO(jieyu): Add UPX compression.
$(DIST_BINARIES): FORCE
	@mkdir -p "$(DIST_DIR)"
	go build -o "$(DIST_DIR)/$(@F)" "./cmd/$(@F)"

FORCE:
