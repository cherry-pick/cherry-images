#
# Maintenance Scripts
#
# This Makefile contains the build-instructions for all images, as well as a
# collection of maintenance targets for development.
#

DEPLOY			?= no
DOCKER			?= docker
SHELL			:= /bin/bash

TAG			?= latest
ARCH			?= x86_64
ARCH_HOST		?= x86_64

CI_BASE			?= fedora-vmbase
VMRUN_BASE		?= fedora-ci
FEDORA_RELEASE		?= 27

ifeq ($(ARCH),armv7hl)
  FEDORA_ARCH		= armv7hl
  QEMU_BIN_ARCH		= arm
  QEMU_PKG_ARCH		= arm
else ifeq ($(ARCH),i686)
  FEDORA_ARCH		= i686
  QEMU_BIN_ARCH		= i386
  QEMU_PKG_ARCH		= x86
else ifeq ($(ARCH),ppc64)
  FEDORA_ARCH		= ppc64
  QEMU_BIN_ARCH		= ppc64
  QEMU_PKG_ARCH		= ppc
else ifeq ($(ARCH),ppc64le)
  FEDORA_ARCH		= ppc64le
  QEMU_BIN_ARCH		= ppc64le
  QEMU_PKG_ARCH		= ppc
else ifeq ($(ARCH),s390x)
  FEDORA_ARCH		= s390x
  QEMU_BIN_ARCH		= s390x
  QEMU_PKG_ARCH		= s390x
else ifeq ($(ARCH),x86_64)
  FEDORA_ARCH		= x86_64
  QEMU_BIN_ARCH		= x86_64
  QEMU_PKG_ARCH		= x86
endif

ifeq ($(ARCH_HOST),armv7hl)
  FEDORA_ARCH_HOST	?= armv7hl
else ifeq ($(ARCH_HOST),i686)
  FEDORA_ARCH_HOST	?= i686
else ifeq ($(ARCH_HOST),ppc64)
  FEDORA_ARCH_HOST	?= ppc64
else ifeq ($(ARCH_HOST),ppc64le)
  FEDORA_ARCH_HOST	?= ppc64le
else ifeq ($(ARCH_HOST),s390x)
  FEDORA_ARCH_HOST	?= s390x
else ifeq ($(ARCH_HOST),x86_64)
  FEDORA_ARCH_HOST	?= x86_64
endif

all:
	@echo "Available targets:"
	@echo "         images/*: Build image"
	@echo "        rebuild-*: combined targets"
	@echo "             ci-*: CI targets"
.PHONY: all

#
# images/source targets
#

images/source:
	$(DOCKER) build \
		--tag "cherrypick/cherryimages-source:$(TAG)" \
		images/source
.PHONY: images/source

#
# images/fedora/base targets
#

images/fedora/base:
	{ \
		set -e ; \
		IID=$$($(DOCKER) build \
			-q \
			--build-arg "CHERRY_FEDORA_ARCH=$(FEDORA_ARCH)" \
			--build-arg "CHERRY_FEDORA_RELEASE=$(FEDORA_RELEASE)" \
			images/fedora/base) ; \
		$(DOCKER) run \
			--rm \
			--entrypoint cat \
			"$${IID}" \
			"/var/lib/cherryimages/sysroot.tar" \
			| $(DOCKER) import \
				- \
				"cherrypick/cherryimages-fedora-base:$(ARCH)-$(TAG)" ; \
	}
.PHONY: images/fedora/base

#
# images/fedora/vmbase targets
#

images/fedora/vmbase:
	$(DOCKER) build \
		--tag "cherrypick/cherryimages-fedora-vmbase:$(ARCH)-$(TAG)" \
		--build-arg "CHERRY_FEDORA_ARCH=$(FEDORA_ARCH)" \
		--build-arg "CHERRY_BASE=cherrypick/cherryimages-fedora-base:$(ARCH)-$(TAG)" \
		images/fedora/vmbase
.PHONY: images/fedora/vmbase

#
# images/fedora/ci targets
#

images/fedora/ci:
	$(DOCKER) build \
		--tag "cherrypick/cherryimages-fedora-ci:$(ARCH)-$(TAG)" \
		--build-arg "CHERRY_FEDORA_ARCH=$(FEDORA_ARCH)" \
		--build-arg "CHERRY_BASE=cherrypick/cherryimages-$(CI_BASE):$(ARCH)-$(TAG)" \
		images/fedora/ci
.PHONY: images/fedora/ci

#
# images/fedora/vmrun targets
#

images/fedora/vmrun:
	{ \
		set -e ; \
		CID=$$($(DOCKER) create \
			--rm \
			"cherrypick/cherryimages-$(VMRUN_BASE):$(ARCH)-$(TAG)" \
			"/bin/bash") ; \
		$(DOCKER) export "$${CID}" \
			| ./scripts/mkimage \
				"images/fedora/vmrun/stage-$(FEDORA_ARCH)" ; \
		$(DOCKER) cp \
			"$${CID}:/var/lib/cherryimages/boot/linux" \
			"images/fedora/vmrun/stage-$(FEDORA_ARCH)/" ; \
		$(DOCKER) cp \
			"$${CID}:/var/lib/cherryimages/boot/initrd" \
			"images/fedora/vmrun/stage-$(FEDORA_ARCH)/" ; \
		$(DOCKER) container rm "$${CID}" ; \
	}
	$(DOCKER) build \
		--tag "cherrypick/cherryimages-fedora-vmrun:$(VMRUN_BASE)-$(ARCH_HOST)-to-$(ARCH)-$(TAG)" \
		--build-arg "CHERRY_FEDORA_ARCH=$(FEDORA_ARCH)" \
		--build-arg "CHERRY_FEDORA_ARCH_HOST=$(FEDORA_ARCH_HOST)" \
		--build-arg "CHERRY_BASE=cherrypick/cherryimages-fedora-base:$(ARCH_HOST)-$(TAG)" \
		--build-arg "CHERRY_QEMU_BIN_ARCH=$(QEMU_BIN_ARCH)" \
		--build-arg "CHERRY_QEMU_PKG_ARCH=$(QEMU_PKG_ARCH)" \
		images/fedora/vmrun
	rm -Rf -- "images/fedora/vmrun/stage-$(FEDORA_ARCH)"
.PHONY: images/fedora/vmrun

#
# rebuild-* targets
#

rebuild-vmrun:
	$(MAKE) images/fedora/base
	$(MAKE) images/fedora/vmbase
	$(MAKE) images/fedora/ci
	$(MAKE) images/fedora/vmrun

#
# ci-* targets
#

ci-base:
	$(MAKE) images/fedora/base
	[[ "$(DEPLOY)" != "yes" ]] || \
		$(DOCKER) push "cherrypick/cherryimages-fedora-base:$(ARCH)-$(TAG)"
.PHONY: ci-base

ci-vmbase:
	$(MAKE) images/fedora/vmbase
	[[ "$(DEPLOY)" != "yes" ]] || \
		$(DOCKER) push "cherrypick/cherryimages-fedora-vmbase:$(ARCH)-$(TAG)"
.PHONY: ci-vmbase

ci-ci:
	$(MAKE) images/fedora/ci
	[[ "$(DEPLOY)" != "yes" ]] || \
		$(DOCKER) push "cherrypick/cherryimages-fedora-ci:$(ARCH)-$(TAG)"
.PHONY: ci-ci

ci-vmrun:
	$(MAKE) images/fedora/vmrun
	[[ "$(DEPLOY)" != "yes" ]] || \
		$(DOCKER) push "cherrypick/cherryimages-fedora-vmrun:$(VMRUN_BASE)-$(ARCH_HOST)-to-$(ARCH)-$(TAG)"
.PHONY: ci-vmrun

ci-tag-push:
	@[[ "$(TAG)" != "latest" ]] || { echo "Cannot tag 'latest'" ; exit 1 ; }
	# base
	$(DOCKER) pull cherrypick/cherryimages-fedora-base:$(ARCH)-latest
	$(DOCKER) tag cherrypick/cherryimages-fedora-base:$(ARCH)-latest \
		cherrypick/cherryimages-fedora-base:$(ARCH)-$(TAG)
	$(DOCKER) push cherrypick/cherryimages-fedora-base:$(ARCH)-$(TAG)
	$(DOCKER) image rm cherrypick/cherryimages-fedora-base:$(ARCH)-$(TAG)
	$(DOCKER) image rm cherrypick/cherryimages-fedora-base:$(ARCH)-latest
	# vmbase
	$(DOCKER) pull cherrypick/cherryimages-fedora-vmbase:$(ARCH)-latest
	$(DOCKER) tag cherrypick/cherryimages-fedora-vmbase:$(ARCH)-latest \
		cherrypick/cherryimages-fedora-vmbase:$(ARCH)-$(TAG)
	$(DOCKER) push cherrypick/cherryimages-fedora-vmbase:$(ARCH)-$(TAG)
	$(DOCKER) image rm cherrypick/cherryimages-fedora-vmbase:$(ARCH)-$(TAG)
	$(DOCKER) image rm cherrypick/cherryimages-fedora-vmbase:$(ARCH)-latest
	# ci
	$(DOCKER) pull cherrypick/cherryimages-fedora-ci:$(ARCH)-latest
	$(DOCKER) tag cherrypick/cherryimages-fedora-ci:$(ARCH)-latest \
		cherrypick/cherryimages-fedora-ci:$(ARCH)-$(TAG)
	$(DOCKER) push cherrypick/cherryimages-fedora-ci:$(ARCH)-$(TAG)
	$(DOCKER) image rm cherrypick/cherryimages-fedora-ci:$(ARCH)-$(TAG)
	$(DOCKER) image rm cherrypick/cherryimages-fedora-ci:$(ARCH)-latest
	# vmrun
	$(DOCKER) pull cherrypick/cherryimages-fedora-vmrun:$(VMRUN_BASE)-$(ARCH_HOST)-to-$(ARCH)-latest
	$(DOCKER) tag cherrypick/cherryimages-fedora-vmrun:$(VMRUN_BASE)-$(ARCH_HOST)-to-$(ARCH)-latest \
		cherrypick/cherryimages-fedora-vmrun:$(VMRUN_BASE)-$(ARCH_HOST)-to-$(ARCH)-$(TAG)
	$(DOCKER) push cherrypick/cherryimages-fedora-vmrun:$(VMRUN_BASE)-$(ARCH_HOST)-to-$(ARCH)-$(TAG)
	$(DOCKER) image rm cherrypick/cherryimages-fedora-vmrun:$(VMRUN_BASE)-$(ARCH_HOST)-to-$(ARCH)-$(TAG)
	$(DOCKER) image rm cherrypick/cherryimages-fedora-vmrun:$(VMRUN_BASE)-$(ARCH_HOST)-to-$(ARCH)-latest
.PHONY: ci-tag-push
