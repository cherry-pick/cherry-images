#
# Maintenance Scripts
#
# This Makefile contains the build-instructions for all images, as well as a
# collection of maintenance targets for development.
#

DOCKER			?= docker
SHELL			?= /bin/bash

ARCH			?= x86_64
ARCH_HOST		?= x86_64

VM_BASE			?= fedora-vmbase
FOREIGN_BASE		?= cherrypick/cherryimages-fedora-base:x86_64-latest

ifeq ($(ARCH),x86_64)
  QEMU_BIN_ARCH		= x86_64
  QEMU_PKG_ARCH		= x86
  QEMU_TTY_PREFIX	= ttyS
else ifeq ($(ARCH),i686)
  QEMU_BIN_ARCH		= i386
  QEMU_PKG_ARCH		= x86
  QEMU_TTY_PREFIX	= ttyS
else ifeq ($(ARCH),armv7hl)
  QEMU_BIN_ARCH		= arm
  QEMU_PKG_ARCH		= arm
  QEMU_TTY_PREFIX	= ttyAMA
endif

all:
	@echo "Available targets:"
	@echo "         images/*: Build image"
	@echo "     tag-images/*: Tag image"
	@echo "        rebuild-*: combined targets"
.PHONY: all

#
# images/fedora/base targets
#

images/fedora/base:
	$(DOCKER) build \
		--tag "cherrypick/cherryimages-fedora-base:$(ARCH)-stage" \
		--build-arg "FEDORA_ARCH=$(ARCH)" \
		--build-arg "FEDORA_BASE=$(FOREIGN_BASE)" \
		images/fedora/base
	$(DOCKER) run \
		--rm \
		--entrypoint cat \
		"cherrypick/cherryimages-fedora-base:$(ARCH)-stage" \
		"/usr/src/build/sysroot.tar" \
		| $(DOCKER) import \
			- \
			"cherrypick/cherryimages-fedora-base:$(ARCH)-head"
	$(DOCKER) image rm "cherrypick/cherryimages-fedora-base:$(ARCH)-stage"
.PHONY: images/fedora/base

tag-images/fedora/base:
	$(DOCKER) tag \
		"cherrypick/cherryimages-fedora-base:$(ARCH)-head" \
		"cherrypick/cherryimages-fedora-base:$(ARCH)-latest"
	$(DOCKER) image rm "cherrypick/cherryimages-fedora-base:$(ARCH)-head"
.PHONY: tag-images/fedora/base

#
# images/fedora/vmbase targets
#

images/fedora/vmbase:
	$(DOCKER) build \
		--tag "cherrypick/cherryimages-fedora-vmbase:$(ARCH)-head" \
		--build-arg "FEDORA_ARCH=$(ARCH)" \
		images/fedora/vmbase
.PHONY: images/fedora/vmbase

tag-images/fedora/vmbase:
	$(DOCKER) tag \
		"cherrypick/cherryimages-fedora-vmbase:$(ARCH)-head" \
		"cherrypick/cherryimages-fedora-vmbase:$(ARCH)-latest"
	$(DOCKER) image rm "cherrypick/cherryimages-fedora-vmbase:$(ARCH)-head"
.PHONY: tag-images/fedora/vmbase

#
# images/fedora/ci targets
#

images/fedora/ci:
	$(DOCKER) build \
		--tag "cherrypick/cherryimages-fedora-ci:$(ARCH)-head" \
		--build-arg "FEDORA_ARCH=$(ARCH)" \
		images/fedora/ci
.PHONY: images/fedora/ci

tag-images/fedora/ci:
	$(DOCKER) tag \
		"cherrypick/cherryimages-fedora-ci:$(ARCH)-head" \
		"cherrypick/cherryimages-fedora-ci:$(ARCH)-latest"
	$(DOCKER) image rm "cherrypick/cherryimages-fedora-ci:$(ARCH)-head"
.PHONY: tag-images/fedora/ci

#
# images/fedora/vmrun targets
#

images/fedora/vmrun:
	{ \
		set -e ; \
		CID=$$($(DOCKER) create \
			--rm \
			"cherrypick/cherryimages-$(VM_BASE):$(ARCH)-latest" \
			"/bin/bash") ; \
		$(DOCKER) export "$${CID}" \
			| ./scripts/mkimage \
				"images/fedora/vmrun/stage-$(ARCH)" ; \
		$(DOCKER) cp \
			"$${CID}:/var/lib/cherryimages/boot/linux" \
			"images/fedora/vmrun/stage-$(ARCH)/" ; \
		$(DOCKER) cp \
			"$${CID}:/var/lib/cherryimages/boot/initrd" \
			"images/fedora/vmrun/stage-$(ARCH)/" ; \
		$(DOCKER) container rm "$${CID}" ; \
	}
	$(DOCKER) build \
		--tag "cherrypick/cherryimages-fedora-vmrun:$(VM_BASE)-$(ARCH_HOST)-to-$(ARCH)-head" \
		--build-arg "FEDORA_ARCH=$(ARCH_HOST)" \
		--build-arg "FEDORA_ARCH_TARGET=$(ARCH)" \
		--build-arg "QEMU_BIN_ARCH=$(QEMU_BIN_ARCH)" \
		--build-arg "QEMU_PKG_ARCH=$(QEMU_PKG_ARCH)" \
		--build-arg "QEMU_TTY_PREFIX=$(QEMU_TTY_PREFIX)" \
		images/fedora/vmrun
	rm -Rf -- "images/fedora/vmrun/stage-$(ARCH)"
.PHONY: images/fedora/vmrun

tag-images/fedora/vmrun:
	$(DOCKER) tag \
		"cherrypick/cherryimages-fedora-vmrun:$(VM_BASE)-$(ARCH_HOST)-to-$(ARCH)-head" \
		"cherrypick/cherryimages-fedora-vmrun:$(VM_BASE)-$(ARCH_HOST)-to-$(ARCH)-latest"
	$(DOCKER) image rm "cherrypick/cherryimages-fedora-vmrun:$(VM_BASE)-$(ARCH_HOST)-to-$(ARCH)-head"
.PHONY: tag-images/fedora/vmrun

#
# rebuild-* targets
#

rebuild-vmrun:
	$(MAKE) images/fedora/base
	$(MAKE) tag-images/fedora/base
	$(MAKE) images/fedora/vmbase
	$(MAKE) tag-images/fedora/vmbase
	$(MAKE) images/fedora/ci
	$(MAKE) tag-images/fedora/ci
	$(MAKE) images/fedora/vmrun
	$(MAKE) tag-images/fedora/vmrun

rebuild-x86_64:
	$(MAKE) rebuild-vmrun ARCH=x86_64
.PHONY: rebuild-x86_64

rebuild-i686:
	$(MAKE) rebuild-vmrun ARCH=i686
.PHONY: rebuild-i686

rebuild-armv7hl:
	$(MAKE) rebuild-vmrun ARCH=armv7hl
.PHONY: rebuild-armv7hl

#
# push targets
#

push:
	$(DOCKER) push cherrypick/cherryimages-fedora-base:$(ARCH)-latest
	$(DOCKER) push cherrypick/cherryimages-fedora-vmbase:$(ARCH)-latest
	$(DOCKER) push cherrypick/cherryimages-fedora-ci:$(ARCH)-latest
	$(DOCKER) push cherrypick/cherryimages-fedora-vmrun:$(VM_BASE)-$(ARCH_HOST)-to-$(ARCH)-latest
.PHONY: push

#
# ci-* targets
#

ci-pre:
	# x86_64 base image is used throughout
	$(MAKE) images/fedora/base
	$(MAKE) tag-images/fedora/base
.PHONY: ci-pre

ci-x86_64:
	# WIP
.PHONY: ci-x86_64

ci-i686:
	$(MAKE) images/fedora/base ARCH=i686
	$(MAKE) tag-images/fedora/base ARCH=i686
.PHONY: ci-i686

ci-armv7hl:
	# WIP
.PHONY: ci-armv7hl
