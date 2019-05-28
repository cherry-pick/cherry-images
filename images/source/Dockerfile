#
# cherry-images - source
#
# The 'source' image is just a plain source repository meant to be used by
# other images as intermediate build-step and shared source image. To build it,
# we use a fedora image as base and fetch all resources into
# /var/lib/cherryimages/. As second step, we discard the fedora base and create
# a scratch image with just /var/lib/cherryimages/ in it.
#
# Right now we include the following resources in it:
#
#     * qemu-user-static in ./qemu/
#       We fetch static builds from github.com/multiarch/ and place them in
#       ./qemu/qemu-${arch}-static. This is because Fedora has no single
#       package for each architecture, nor does it build it for all target
#       architectues. Hence, we simply use our own.
#
# Options:
#
#     CHERRY_QEMU_ARCHS: Architectures to fetch qemu builds for.
#
#     CHERRY_QEMU_SOURCE: Source URL to fetch static qemu builds from.
#
#     CHERRY_QEMU_VERSION: Qemu version to fetch.
#

FROM fedora AS bootstrap

ARG CHERRY_QEMU_ARCHS="arm i386 ppc64 ppc64le s390x x86_64"
ARG CHERRY_QEMU_SOURCE="https://github.com/multiarch/qemu-user-static/releases/download/"
ARG CHERRY_QEMU_VERSION=v4.0.0

#
# qemu-user-static
#
# Provide qemu-*-static binaries in the 'qemu' subdirectory. We fetch the
# prebuilt binaries from the multiarch project and provide them to subbuilds.
#
#

RUN mkdir -p "/var/lib/cherryimages/qemu/"
RUN cd "/var/lib/cherryimages/qemu/" \
        && for arch in ${CHERRY_QEMU_ARCHS} ; do \
                curl -O -L "${CHERRY_QEMU_SOURCE}/${CHERRY_QEMU_VERSION}/qemu-${arch}-static" ; \
        done
RUN chmod +x /var/lib/cherryimages/qemu/qemu-*-static

#
# Extract Sources
#
# Discard the bootstrap image and create a new one from scratch. It has no
# contents whatsoever. We then import the source directory from the bootstrap
# image.
#

FROM scratch AS main
COPY --from=bootstrap /var/lib/cherryimages/ /var/lib/cherryimages/
