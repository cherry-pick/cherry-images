ARG FEDORA_ARCH=x86_64
ARG FEDORA_BASE=cherrypick/cherryimages-fedora-base:${FEDORA_ARCH}-latest
FROM ${FEDORA_BASE}
ARG FEDORA_ARCH

#
# cherry-images - fedora CI
#
# The 'fedora-ci' image is a Fedora OS image based on the 'fedora-base'
# cherry-image. It simply adds packages required by basic CI systems.
#
# Options:
#
#     FEDORA_ARCH: Fedora architecture to build. This defaults to x86_64.
#
#     FEDORA_BASE: Fedora base image to build on. This defaults to:
#                  `cherrypick/cherryimages-fedora-base:${FEDORA_ARCH}-latest`
#
#

RUN dnf -y --nodocs --forcearch="${FEDORA_ARCH}" update \
        && dnf -y --nodocs --forcearch="${FEDORA_ARCH}" install \
                autoconf \
                automake \
                binutils-devel \
                bison-devel \
                clang \
                coreutils \
                dbus-devel \
                expat-devel \
                flex-devel \
                gawk \
                gcc \
                gdb \
                gettext \
                git \
                glib2-devel \
                glibc-devel \
                grep \
                groff \
                gzip \
                libtool \
                m4 \
                make \
                meson \
                ninja-build \
                patch \
                pkgconf \
                python2-docutils \
                rust \
                sed \
                strace \
                sudo \
                systemd-devel \
                tar \
                texinfo \
                util-linux \
                which \
                valgrind \
        && dnf clean all
