include PACKAGE

DIST_BINARIES := \
  $(DIST_DIR)/module-source-converter

.PHONY: init
init:
	git submodule update --init

.PHONY: release
release:
	git submodule foreach bash -c '\
	if $$(git status | grep -q modified:); then \
	   git checkout -b $(branch); \
	   git add -A; \
	   git commit; \
	   git push origin $(branch); \
	   hub pull-request; \
	fi' 

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
