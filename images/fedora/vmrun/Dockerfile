ARG FEDORA_ARCH=x86_64
ARG FEDORA_BASE=cherrypick/cherryimages-fedora-base:${FEDORA_ARCH}-latest
FROM ${FEDORA_BASE}
ARG FEDORA_ARCH
ARG FEDORA_ARCH_TARGET=x86_64
ARG QEMU_BIN_ARCH=x86_64
ARG QEMU_PKG_ARCH=x86

ENV FEDORA_ARCH=${FEDORA_ARCH}
ENV FEDORA_ARCH_TARGET=${FEDORA_ARCH_TARGET}
ENV QEMU_BIN_ARCH=${QEMU_BIN_ARCH}
ENV QEMU_PKG_ARCH=${QEMU_PKG_ARCH}

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
#     FEDORA_ARCH: Fedora architecture to build. This defaults to x86_64.
#
#     FEDORA_ARCH_TARGET: Fedora target architecture to emulate. This defaults
#                         to x86_64.
#
#     FEDORA_BASE: Fedora base image to build on. This defaults to:
#                  `cherrypick/cherryimages-fedora-base:${FEDORA_ARCH}-latest`
#
#     QEMU_BIN_ARCH: Qemu architecture suffix for binary. Defaults to x86_64.
#
#     QEMU_PKG_ARCH: Qemu architecture suffix for fedora package. Defaults to
#                    x86.
#

#
# Install requirements
#

RUN dnf -y --nodocs update \
        && dnf \
                -y \
                --nodocs \
                --forcearch="${FEDORA_ARCH}" \
                --setopt=install_weak_deps=False \
                install \
                        "qemu-system-${QEMU_PKG_ARCH}" \
                        "qemu-img" \
        && dnf clean all

#
# Copy image
#

RUN mkdir -p "/mnt/cherryimages" "/mnt/cherryimages/input"
ADD \
        "stage-${FEDORA_ARCH_TARGET}" \
        "/mnt/cherryimages/stage-${FEDORA_ARCH_TARGET}"
ADD "entrypoint" "/mnt/cherryimages/"

#
# Configure entrypoint
#

ENTRYPOINT ["/mnt/cherryimages/entrypoint"]
