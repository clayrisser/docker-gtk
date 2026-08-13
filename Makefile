.POSIX:
export ROOTDIR ?= $(eval ROOTDIR := $(shell git rev-parse --show-toplevel))$(ROOTDIR)
include $(ROOTDIR)/make.mk

.DEFAULT_GOAL := build

.PHONY: build
build: configure docker/bake

# run: forwards the host display into the container. Prefers Wayland when a
# compositor socket is available, falls back to X11, and with no display at
# all the image's entrypoint renders headlessly to Xvfb inside the container.
.PHONY: run
run:
	@if [ -n "$$WAYLAND_DISPLAY" ] && [ -S "$$XDG_RUNTIME_DIR/$$WAYLAND_DISPLAY" ]; then \
		$(DOCKER) run -it --rm \
			-e WAYLAND_DISPLAY \
			-e XDG_RUNTIME_DIR=/tmp/xdg-runtime \
			-v "$$XDG_RUNTIME_DIR/$$WAYLAND_DISPLAY:/tmp/xdg-runtime/$$WAYLAND_DISPLAY" \
			$(DOCKER_REGISTRY)/docker-gtk:$(DOCKER_TAG); \
	elif [ -n "$$DISPLAY" ]; then \
		$(DOCKER) run -it --rm \
			-e DISPLAY \
			-v /tmp/.X11-unix:/tmp/.X11-unix \
			$(DOCKER_REGISTRY)/docker-gtk:$(DOCKER_TAG); \
	else \
		echo "no display detected, running headless (Xvfb inside the container)" >&2; \
		$(DOCKER) run -it --rm $(DOCKER_REGISTRY)/docker-gtk:$(DOCKER_TAG); \
	fi

.PHONY: test/e2e
test/e2e: configure
	@cd tests && export PROJECT_ROOT=$(ROOTDIR) && \
		trap './teardown.sh' EXIT INT TERM; \
		./setup.sh && $(BATS) .

# Shared (used by both format and lint)
_SHFILES = $(GIT) ls-files '*.sh' '*.bats'

.PHONY: format
format: configure
	@$(_SHFILES) | xargs $(SHFMT) -w

.PHONY: lint
lint: configure
	@$(_SHFILES) | xargs $(SHFMT) -d

.PHONY: count
count: configure
	@$(CLOC) $$($(GIT) ls-files)

.PHONY: clean
clean:
	@rm -rf $(MAKEDIR) .dockerignore

.PHONY: purge
purge: clean
	@$(GIT) clean -fxd

.PHONY: docker docker/%
docker: FORCE
	@$(MAKE) -C docker
docker/%: FORCE
	@$(MAKE) -C docker $*

.PHONY: configure
configure:
	@for cmd in asdf $(CLOC); do \
		command -v $$cmd >/dev/null 2>&1 || { echo "$$cmd is missing, run \`make prepare\`"; exit 1; }; \
	done
	@awk '!/^#/ && NF {print $$1}' $(ROOTDIR)/.tool-versions | \
		while read t; do asdf plugin add "$$t" 2>/dev/null || true; done
	@rcfile=$$(mktemp); \
		{ asdf install 2>&1; echo $$? >$$rcfile; } | grep --line-buffered -v 'is already installed' || true; \
		rc=$$(cat $$rcfile); rm -f $$rcfile; exit $$rc
	@for cmd in $(BATS) $(SHFMT) docker; do \
		command -v $$cmd >/dev/null 2>&1 || { echo "$$cmd is missing, run \`make prepare\`"; exit 1; }; \
	done

ASDF_VERSION ?= v0.18.0
.PHONY: prepare prepare/asdf prepare/cloc
prepare: sudo
	@command -v asdf >/dev/null 2>&1 || $(MAKE) prepare/asdf
	@command -v cloc >/dev/null 2>&1 || $(MAKE) prepare/cloc
	@awk '!/^#/ && NF {print $$1}' $(ROOTDIR)/.tool-versions | \
		while read t; do asdf plugin add "$$t" 2>/dev/null || true; done
	@rcfile=$$(mktemp); \
		{ asdf install 2>&1; echo $$? >$$rcfile; } | grep --line-buffered -v 'is already installed' || true; \
		rc=$$(cat $$rcfile); rm -f $$rcfile; exit $$rc
prepare/asdf:
	@command -v brew >/dev/null 2>&1 && brew install asdf || { \
		o=$$(uname | tr A-Z a-z); a=$$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/'); \
		curl -fsSL "https://github.com/asdf-vm/asdf/releases/download/$(ASDF_VERSION)/asdf-$(ASDF_VERSION)-$$o-$$a.tar.gz" \
			| $(SUDO) tar -xz -C /usr/local/bin asdf; \
	}
prepare/cloc:
	@$(PKG_INSTALL) cloc
