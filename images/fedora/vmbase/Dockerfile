#
# cherry-images - fedora vmbase
#
# This image builds on top of the fedora-base image, adding a kernel and initrd
# prepared to run this image in a virtual machine. Furthermore, it prepares all
# the required user-space utilities, so the machine can be booted properly. It
# adds the infrastructure required to be used as base-image for the vmrun
# utility.
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

#
# Configure dracut
#

RUN mkdir -p -m 0755 "/etc" "/etc/kernel" "/etc/dracut.conf.d"
RUN echo "add_dracutmodules+=\" qemu \"" >"/etc/dracut.conf.d/cherryimages.conf"
RUN echo "dummy.cmdline" >"/etc/kernel/cmdline" # must be non-empty

#
# Bootstrap packages
#

RUN dnf \
                -y \
                -v \
                --nodocs \
                --forcearch="${CHERRY_FEDORA_ARCH}" \
                --setopt=install_weak_deps=False \
                --exclude grubby \
                install \
                        bash \
                        coreutils \
                        dracut-config-generic \
                        fedora-release \
                        kernel \
                        shadow-utils \
                        sudo \
                        systemd \
                        util-linux \
                        util-linux-user \
        && dnf clean all

RUN systemd-firstboot \
        --locale=en_US.UTF-8 \
        --timezone=UTC \
        --hostname=cherryimages \
        --root-password= \
        --setup-machine-id

#
# Allow login as root
#

RUN echo "root:" | chpasswd

#
# Create cherryimages user
#

RUN echo "u cherryimages - - /var/lib/cherryimages/home" >"/usr/lib/sysusers.d/cherryimages.conf"
RUN systemd-sysusers
RUN echo "cherryimages ALL=(ALL) NOPASSWD: ALL" >>"/etc/sudoers"
RUN chsh -s "/bin/bash" "cherryimages"

#
# Create scratch directory
#

RUN mkdir -p "/var/lib/cherryimages" \
             "/var/lib/cherryimages/bin" \
             "/var/lib/cherryimages/home" \
             "/var/lib/cherryimages/src"
RUN chown -R cherryimages:cherryimages "/var/lib/cherryimages"

#
# Generate initrd and remember the location
#

RUN mkdir -p "/boot/$(cat "/etc/machine-id")"
RUN kernel-install \
        "add" \
        "$(rpm -q --qf "%{version}-%{release}.%{arch}" kernel)" \
        "/lib/modules/$(rpm -q --qf "%{version}-%{release}.%{arch}" kernel)/vmlinuz"
RUN ln -s \
        "/boot/$(cat "/etc/machine-id")/$(rpm -q --qf "%{version}-%{release}.%{arch}" kernel)/" \
        "/var/lib/cherryimages/boot"

#
# Setup default network
#

RUN echo -e "[Match]\nName=en*\n[Network]\nDHCP=yes" \
        >/etc/systemd/network/50-cherryimages.network
RUN echo "L+ /etc/resolv.conf - - - - ../run/systemd/resolve/resolv.conf" \
        >/etc/tmpfiles.d/cherryimages.conf
RUN systemctl enable systemd-networkd.service
RUN systemctl enable systemd-resolved.service

#
# Disable automatic serial-line occupation by GETTYs
#

RUN mkdir -p /etc/systemd/system-generators
RUN ln -s /dev/null /etc/systemd/system-generators/systemd-getty-generator

#
# Disable automated dnf metadata updates
#

RUN systemctl disable dnf-makecache.service
RUN systemctl disable dnf-makecache.timer

#
# Import configuration
#

ADD "cherryimages@.service" "/etc/systemd/system"
ADD "cherryimages-getty@.service" "/etc/systemd/system"
ADD "cherryimages-shell@.service" "/etc/systemd/system"
ADD "var-lib-cherryimages-bin.mount" "/etc/systemd/system"
ADD "var-lib-cherryimages-src.mount" "/etc/systemd/system"
ADD "cherryimages-modules.conf" "/etc/modules-load.d/"
