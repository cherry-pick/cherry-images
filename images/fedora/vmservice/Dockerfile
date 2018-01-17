ARG FEDORA_ARCH=x86_64
ARG FEDORA_BASE=cherrypick/cherryimages-fedora-boot:${FEDORA_ARCH}-latest
FROM ${FEDORA_BASE}
ARG FEDORA_ARCH
ARG FEDORA_TTY_OUTPUT

#
# cherry-images - fedora vmservice
#
# This images builds on top of fedora-boot, adding a default execution unit.
# This means, if booted via /sbin/init, this will execute a specially creafted
# service that executes a custom script, eventually halting the machine when
# done.
#
# When this image is booted (either in a container of VM), it will run the
# normal fedora systemd startup and eventually pull in a special service file
# that executes /mnt/cherryimages/bin/main. Once that process finishes, the
# service file will trigger a poweroff. If anything fails in between, a
# poweroff is triggered as well. Note that /mnt/cherryimages/bin is mounted
# from /dev/vdb1, so the caller must provide it via some means. It is expected
# to be a READ-ONLY vfat-compatible filesystem.
#
# When everything went as expected, 'success' is written to FEDORA_TTY_OUTPUT,
# so the caller can detect whether the script in question was executed
# successfully, or whether something failed.
#
# This service can use different images based on fedora-boot as base. Just set
# the FEDORA_BASE variable to select a different base.
#
# Options:
#
#     FEDORA_ARCH: Fedora architecture to build. This defaults to x86_64.
#
#     FEDORA_BASE: Fedora base image to build on. This defaults to:
#                  `cherrypick/cherryimages-fedora-boot:${FEDORA_ARCH}-latest`
#
#     FEDORA_TTY_OUTPUT: TTY to use for "success" output. Usually something
#                        like /dev/ttyS1 or /dev/ttyAMA1.
#

#
# Create scratch directory
#

RUN mkdir -p \
        "/mnt/cherryimages/" \
        "/mnt/cherryimages/bin" \
        "/mnt/cherryimages/src"

#
# Create TTY symlink
#

RUN ln -s "${FEDORA_TTY_OUTPUT}" "/mnt/cherryimages/tty-output"

#
# Copy configuration
#

ADD "cherryimages.service" "/etc/systemd/system"
ADD "mnt-cherryimages-bin.mount" "/etc/systemd/system"
ADD "mnt-cherryimages-src.mount" "/etc/systemd/system"
ADD "cherryimages-modules.conf" "/etc/modules-load.d/"

#
# Post-install
#

RUN ln -s \
        "/etc/systemd/system/cherryimages.service" \
        "/etc/systemd/system/multi-user.target.wants/cherryimages.service"
