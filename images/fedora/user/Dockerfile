ARG FEDORA_ARCH=x86_64
ARG FEDORA_BASE=cherrypick/cherryimages-fedora-base:${FEDORA_ARCH}-latest
FROM ${FEDORA_BASE}
ARG FEDORA_ARCH

#
# cherry-images - fedora user
#
# The 'fedora-user' image is a Fedora OS image based on the 'fedora-base'
# cherry-image. It adds a basic runtime layer to the base image, ready to be
# used to run applications. It adds:
#
#     * bash, coreutils, shadow-utils:
#           The bash shell is installed and prepared for use alongside the most
#           basic linux tools.
#
#     * systemd:
#           The systemd management application is installed and configured to
#           boot and run the system. The system locale is set to en_US.UTF-8,
#           the hostname becomes 'cherryimages', the timezone is set to UTC,
#           and a machine-id is generated.
#
#     * users:
#           The root-user is configured with an empty password. Additionally,
#           the 'cherryimages' user is added, including its home directory,
#           unconditional sudo access, and an empty password.
#
# Options:
#
#     FEDORA_ARCH: Fedora architecture to build. This defaults to x86_64.
#
#     FEDORA_BASE: Fedora base image to build on. This defaults to:
#                  `cherrypick/cherryimages-fedora-base:${FEDORA_ARCH}-latest`
#

#
# Bootstrap systemd+base and configure it
#

RUN dnf -y --nodocs --forcearch="${FEDORA_ARCH}" update \
        && dnf -y --nodocs --forcearch="${FEDORA_ARCH}" install \
                bash \
                coreutils \
                fedora-release \
                shadow-utils \
                sudo \
                systemd \
                util-linux \
                util-linux-user \
        && dnf clean all

RUN echo \
        "u cherryimages - - /home/cherryimages" \
        >"/usr/lib/sysusers.d/cherryimages.conf"
RUN echo \
        "cherryimages ALL=(ALL) NOPASSWD: ALL" \
        >>"/etc/sudoers"

RUN systemd-firstboot \
        --locale=en_US.UTF-8 \
        --timezone=UTC \
        --hostname=cherryimages \
        --root-password= \
        --setup-machine-id
RUN systemd-sysusers

RUN mkdir -p "/home/cherryimages"
RUN echo -e "root:\ncherryimages:" | chpasswd
RUN chsh -s "/bin/bash" "cherryimages"

RUN echo -e "[Match]\nName=en*\n[Network]\nDHCP=yes" \
        >/etc/systemd/network/50-cherryimages.network
RUN echo "L+ /etc/resolv.conf - - - - ../run/systemd/resolve/resolv.conf" \
        >/etc/tmpfiles.d/cherryimages.conf
RUN systemctl enable systemd-networkd.service
RUN systemctl enable systemd-resolved.service

RUN mkdir -p /etc/systemd/system-generators
RUN ln -s /dev/null /etc/systemd/system-generators/systemd-getty-generator

#
# Disable automated dnf metadata updates
#

RUN systemctl disable dnf-makecache.service
RUN systemctl disable dnf-makecache.timer
