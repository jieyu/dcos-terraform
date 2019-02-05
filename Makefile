include PACKAGE

DIST_BINARIES := \
  $(DIST_DIR)/module-source-converter

BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD)

.PHONY: init
init:
	git submodule update --init

.PHONY: deinit
deinit:
	git submodule deinit --all -f

.PHONY: branch
branch:
	git checkout $(BRANCH) || git checkout -b $(BRANCH)
	git submodule foreach "git checkout $(BRANCH) || git checkout -b $(BRANCH)"

.PHONY: pull
pull:
	git submodule foreach "git pull"

.PHONY: rebase
rebase:
	git submodule foreach "git rebase master"

.PHONY: upstream
upstream:
	git submodule foreach "BRANCH=$(BRANCH) $(CURDIR)/scripts/upstream-changes.sh"

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
