include PACKAGE

DIST_BINARIES := \
  $(DIST_DIR)/module-source-converter

BRANCH ?= $(shell uuidgen)

.PHONY: init
init:
	git submodule update --init

.PHONY: deinit
deinit:
	git submodule deinit --all -f

.PHONY: release
release:
	git submodule foreach "BRANCH=$(BRANCH) $(CURDIR)/scripts/submit-pull-requests.sh"

.PHONY: ssh-git
ssh-git:
	sed -i.bak -e 's/https:\/\/github.com\//git@github.com:/g' .gitmodules
	rm .gitmodules.bak
	git submodule sync

.PHONY: http-git
http-git:
	sed -i.bak -e 's/git@github.com:/https:\/\/github.com\//g' .gitmodules
	rm .gitmodules.bak
	git submodule sync

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
