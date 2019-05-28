#
# cherry-images - fedora vmrun
#
# This image builds on top of the most basic fedora image, pulling in qemu of a
# specific target architecture. Furthermore, it imports a staging directory
# which must be previously built via the script `./scripts/mkimage`. This
# staging directory will then contain a VM image that will be included in this
# container, and is executed when the container is run.
#
# Options:
#
#     CHERRY_FEDORA_ARCH: Fedora architecture to build for.
#
#     CHERRY_FEDORA_ARCH_HOST: Fedora architecture to build on.
#
#     CHERRY_BASE: Base image to build on.
#
#     CHERRY_QEMU_BIN_ARCH: Qemu architecture suffix for binary.
#
#     CHERRY_QEMU_PKG_ARCH: Qemu architecture suffix for fedora package.
#

ARG CHERRY_BASE
FROM ${CHERRY_BASE}
ARG CHERRY_FEDORA_ARCH
ARG CHERRY_FEDORA_ARCH_HOST
ARG CHERRY_QEMU_BIN_ARCH
ARG CHERRY_QEMU_PKG_ARCH

ENV CHERRY_FEDORA_ARCH=${CHERRY_FEDORA_ARCH}
ENV CHERRY_FEDORA_ARCH_HOST=${CHERRY_FEDORA_ARCH_HOST}
ENV CHERRY_QEMU_BIN_ARCH=${CHERRY_QEMU_BIN_ARCH}
ENV CHERRY_QEMU_PKG_ARCH=${CHERRY_QEMU_PKG_ARCH}

#
# Install requirements
#

RUN dnf \
        -y \
        -v \
        --nodocs \
        --forcearch="${CHERRY_FEDORA_ARCH_HOST}" \
        --setopt=install_weak_deps=False \
        install \
                "qemu-system-${CHERRY_QEMU_PKG_ARCH}" \
                "qemu-img" \
        && dnf clean all

#
# Copy image
#

RUN mkdir -p \
        "/var/lib/cherryimages/" \
        "/var/lib/cherryimages/bin" \
        "/var/lib/cherryimages/src"
ADD \
        "stage-${CHERRY_FEDORA_ARCH}" \
        "/var/lib/cherryimages/stage-${CHERRY_FEDORA_ARCH}"
ADD "entrypoint" "/var/lib/cherryimages/"

#
# Configure entrypoint
#

ENTRYPOINT ["/var/lib/cherryimages/entrypoint"]
