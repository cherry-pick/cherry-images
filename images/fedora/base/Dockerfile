ARG FEDORA_ARCH=x86_64
ARG FEDORA_BASE=cherrypick/cherryimages-fedora-base:${FEDORA_ARCH}-latest
FROM ${FEDORA_BASE}
ARG FEDORA_ARCH
ARG FEDORA_RELEASE=27

#
# cherry-images - fedora base
#
# The 'fedora-base' image is a Fedora OS image with just the 'bash' and 'dnf'
# packages installed. In other words, it contains the minimal amount of
# packages to be suitable to install any other Fedora package.
#
# Note that this Dockerfile is self-hosting. That is, it depends on a previous
# build of itself. If such an image is not available (e.g., bootstrapping a
# foreign architecture), you should use an existing image with qemu-user-static
# for the target architecture installed.
#
# Be aware that this Dockerfile does not create the final image! On the
# contrary, it bootstraps the 'fedora-base' image into /usr/src/build/sysroot
# and provides a tarball of that directory as /usr/src/build/sysroot.tar. You
# should copy it out of there and import it into docker to get your new
# 'fedora-base' image. For instance, the following commands use this Dockerfile
# to build 'myimage', and then import it as new base-image as
# 'cherrypick/cherryimages-fedora-base:i686-latest'.
#
#       docker build \
#               -t myimage \
#               --build-arg FEDORA_ARCH=i686 \
#               images/fedora/base
#
#       docker run \
#               --rm \
#               --entrypoint cat \
#               myimage \
#               /usr/src/build/sysroot.tar | \
#                       docker import \
#                               - \
#                               cherrypick/cherryimages-fedora-base:i686-latest
#
# Options:
#
#     FEDORA_ARCH: Fedora architecture to build. This defaults to x86_64.
#
#     FEDORA_BASE: Fedora base image to build on. This defaults to:
#                  `cherrypick/cherryimages-fedora-base:${FEDORA_ARCH}-latest`
#
#     FEDORA_RELEASE: The fedora release to build. This is updated to the
#                     latest release automatically.
#

RUN dnf -y --nodocs update \
        && dnf -y --nodocs install \
                coreutils \
                tar \
        && dnf clean all

RUN mkdir -p /usr/src/build/sysroot

RUN dnf -y --nodocs update \
        && dnf \
                -y \
                --nodocs \
                --repo=fedora \
                --repo=updates \
                --releasever="${FEDORA_RELEASE}" \
                --forcearch="${FEDORA_ARCH}" \
                --installroot=/usr/src/build/sysroot \
                --setopt=install_weak_deps=False \
                install \
                        bash \
                        dnf \
                        fedora-release \
        && dnf clean all

RUN tar \
        --acls \
        --xattrs \
        --numeric-owner \
        -cf /usr/src/build/sysroot.tar \
        -C /usr/src/build/sysroot \
        .
