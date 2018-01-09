ARG FEDORA_ARCH=x86_64
ARG FEDORA_BASE=cherrypick/cherryimages-fedora-user:${FEDORA_ARCH}-latest
FROM ${FEDORA_BASE}
ARG FEDORA_ARCH

#
# cherry-images - fedora boot
#
# This image builds on top of the fedora-user image, adding a kernel and initrd
# prepared to run this image in a virtual machine.
#
# Options:
#
#     FEDORA_ARCH: Fedora architecture to build. This defaults to x86_64.
#
#     FEDORA_BASE: Fedora base image to build on. This defaults to:
#                  `cherrypick/cherryimages-fedora-user:${FEDORA_ARCH}-latest`
#

#
# Create scratch directory
#

RUN mkdir -p "/mnt/cherryimages"

#
# Configure dracut
#

RUN mkdir -p -m 0755 "/etc" "/etc/kernel" "/etc/dracut.conf.d"
RUN echo "add_dracutmodules+=\" qemu \"" >"/etc/dracut.conf.d/cherryimages.conf"
RUN echo "dummy.cmdline" >"/etc/kernel/cmdline" # must be non-empty

#
# Bootstrap kernel+dracut
#

RUN dnf -y --nodocs --forcearch="${FEDORA_ARCH}" update \
        && dnf -y --nodocs --forcearch="${FEDORA_ARCH}" \
                --exclude grubby \
                install \
                        dracut-config-generic \
                        kernel \
        && dnf clean all

#
# Post-install
#

RUN ln -s \
        "/boot/$(cat "/etc/machine-id")/$(rpm -q --qf "%{version}-%{release}.%{arch}" kernel)/" \
        "/mnt/cherryimages/boot"
