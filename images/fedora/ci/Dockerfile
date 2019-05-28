#
# cherry-images - fedora CI
#
# The 'fedora-ci' image is a Fedora OS image based on the 'fedora-base'
# cherry-image. It simply adds packages required by basic CI systems.
#
# Options:
#
#     CHERRY_FEDORA_ARCH: Fedora architecture to build.
#
#     CHERRY_BASE: Base image to build on.
#

ARG CHERRY_BASE
FROM ${CHERRY_BASE}
ARG CHERRY_FEDORA_ARCH

RUN dnf \
        -y \
        -v \
        --nodocs \
        --forcearch="${CHERRY_FEDORA_ARCH}" \
        --setopt=install_weak_deps=False \
        install \
                audit-libs-devel \
                autoconf \
                automake \
                binutils-devel \
                bison-devel \
                clang \
                coreutils \
                dbus-devel \
                expat-devel \
                file \
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
                htop \
                iproute \
                libcap-ng-devel \
                libtool \
                libselinux-devel \
                lld \
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
                vim \
        && dnf clean all
