#
# Maintenance Scripts
#
# This Makefile contains a random selection of targets for easy development.
# They mostly serve as example how most of the build/test infrastructure is
# used. Feel free to adjust them to your needs.
#

DOCKER			?= docker
SHELL			?= /bin/bash

ARCH			?= x86_64
ARCH_TARGET		?= x86_64
QEMU_BIN_ARCH		?= x86_64
QEMU_PKG_ARCH		?= x86

VM_TARGET		?= ci
FOREIGN_BASE		?= cherrypick/cherryimages-fedora-base:x86_64-latest

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
# images/fedora/user targets
#

images/fedora/user:
	$(DOCKER) build \
		--tag "cherrypick/cherryimages-fedora-user:$(ARCH)-head" \
		--build-arg "FEDORA_ARCH=$(ARCH)" \
		images/fedora/user
.PHONY: images/fedora/user

tag-images/fedora/user:
	$(DOCKER) tag \
		"cherrypick/cherryimages-fedora-user:$(ARCH)-head" \
		"cherrypick/cherryimages-fedora-user:$(ARCH)-latest"
	$(DOCKER) image rm "cherrypick/cherryimages-fedora-user:$(ARCH)-head"
.PHONY: tag-images/fedora/user

#
# images/fedora/boot targets
#

images/fedora/boot:
	$(DOCKER) build \
		--tag "cherrypick/cherryimages-fedora-boot:$(ARCH)-head" \
		--build-arg "FEDORA_ARCH=$(ARCH)" \
		images/fedora/boot
.PHONY: images/fedora/boot

tag-images/fedora/boot:
	$(DOCKER) tag \
		"cherrypick/cherryimages-fedora-boot:$(ARCH)-head" \
		"cherrypick/cherryimages-fedora-boot:$(ARCH)-latest"
	$(DOCKER) image rm "cherrypick/cherryimages-fedora-boot:$(ARCH)-head"
.PHONY: tag-images/fedora/boot

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
	$(DOCKER) build \
		--tag "cherrypick/cherryimages-fedora-vmservice:$(ARCH_TARGET)-stage" \
		--build-arg "FEDORA_ARCH=$(ARCH_TARGET)" \
		--build-arg "FEDORA_BASE=cherrypick/cherryimages-fedora-$(VM_TARGET):$(ARCH_TARGET)-latest" \
		images/fedora/vmservice
	{ \
		set -e ; \
		CID=$$($(DOCKER) create \
			--rm \
			"cherrypick/cherryimages-fedora-vmservice:$(ARCH_TARGET)-stage" \
			"/bin/bash") ; \
		$(DOCKER) export "$${CID}" \
			| ./scripts/mkimage \
				"images/fedora/vmrun/stage-$(ARCH_TARGET)" ; \
		$(DOCKER) cp \
			"$${CID}:/mnt/cherryimages/boot/linux" \
			"images/fedora/vmrun/stage-$(ARCH_TARGET)/" ; \
		$(DOCKER) cp \
			"$${CID}:/mnt/cherryimages/boot/initrd" \
			"images/fedora/vmrun/stage-$(ARCH_TARGET)/" ; \
		$(DOCKER) container rm "$${CID}" ; \
	}
	$(DOCKER) image rm "cherrypick/cherryimages-fedora-vmservice:$(ARCH_TARGET)-stage"
	$(DOCKER) build \
		--tag "cherrypick/cherryimages-fedora-vmrun:$(VM_TARGET)-$(ARCH)-to-$(ARCH_TARGET)-head" \
		--build-arg "FEDORA_ARCH=$(ARCH)" \
		--build-arg "FEDORA_ARCH_TARGET=$(ARCH_TARGET)" \
		--build-arg "QEMU_BIN_ARCH=$(QEMU_BIN_ARCH)" \
		--build-arg "QEMU_PKG_ARCH=$(QEMU_PKG_ARCH)" \
		images/fedora/vmrun
	rm -Rf -- "images/fedora/vmrun/stage-$(ARCH_TARGET)"
.PHONY: images/fedora/vmrun

tag-images/fedora/vmrun:
	$(DOCKER) tag \
		"cherrypick/cherryimages-fedora-vmrun:$(VM_TARGET)-$(ARCH)-to-$(ARCH_TARGET)-head" \
		"cherrypick/cherryimages-fedora-vmrun:$(VM_TARGET)-$(ARCH)-to-$(ARCH_TARGET)-latest"
	$(DOCKER) image rm "cherrypick/cherryimages-fedora-vmrun:$(VM_TARGET)-$(ARCH)-to-$(ARCH_TARGET)-head"
.PHONY: tag-images/fedora/vmrun

#
# rebuild-* targets
#

rebuild-basic:
	$(MAKE) images/fedora/base \
		ARCH=$(REBUILD)
	$(MAKE) tag-images/fedora/base \
		ARCH=$(REBUILD)
	$(MAKE) images/fedora/user \
		ARCH=$(REBUILD)
	$(MAKE) tag-images/fedora/user \
		ARCH=$(REBUILD)
	$(MAKE) images/fedora/boot \
		ARCH=$(REBUILD)
	$(MAKE) tag-images/fedora/boot \
		ARCH=$(REBUILD)
	$(MAKE) images/fedora/ci \
		ARCH=$(REBUILD)
	$(MAKE) tag-images/fedora/ci \
		ARCH=$(REBUILD)
.PHONY: rebuild-basic

rebuild-x86_64:
	$(MAKE) rebuild-basic REBUILD=x86_64
	$(MAKE) images/fedora/vmrun \
		ARCH=x86_64 \
		ARCH_TARGET=x86_64 \
		QEMU_BIN_ARCH=x86_64 \
		QEMU_PKG_ARCH=x86
	$(MAKE) tag-images/fedora/vmrun \
		ARCH=x86_64 \
		ARCH_TARGET=x86_64
.PHONY: rebuild-x86_64

rebuild-i686:
	$(MAKE) rebuild-basic REBUILD=i686
	$(MAKE) images/fedora/vmrun \
		ARCH=x86_64 \
		ARCH_TARGET=i686 \
		QEMU_BIN_ARCH=i386 \
		QEMU_PKG_ARCH=x86
	$(MAKE) tag-images/fedora/vmrun \
		ARCH=x86_64 \
		ARCH_TARGET=i686
.PHONY: rebuild-i686

rebuild-armv7hl:
	$(MAKE) rebuild-basic REBUILD=armv7hl
	$(MAKE) images/fedora/vmrun \
		ARCH=x86_64 \
		ARCH_TARGET=armv7hl \
		QEMU_BIN_ARCH=arm \
		QEMU_PKG_ARCH=arm
	$(MAKE) tag-images/fedora/vmrun \
		ARCH=x86_64 \
		ARCH_TARGET=armv7hl
.PHONY: rebuild-armv7hl

#
# push targets
#

push:
	$(DOCKER) push cherrypick/cherryimages-fedora-base:$(ARCH_TARGET)-latest
	$(DOCKER) push cherrypick/cherryimages-fedora-user:$(ARCH_TARGET)-latest
	$(DOCKER) push cherrypick/cherryimages-fedora-boot:$(ARCH_TARGET)-latest
	$(DOCKER) push cherrypick/cherryimages-fedora-ci:$(ARCH_TARGET)-latest
	$(DOCKER) push cherrypick/cherryimages-fedora-vmrun:ci-$(ARCH)-to-$(ARCH_TARGET)-latest
.PHONY: push
