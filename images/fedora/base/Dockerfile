#
# cherry-images - fedora base
#
# The 'fedora-base' image is a Fedora OS image with just the 'bash' and 'dnf'
# packages installed. In other words, it contains the minimal amount of
# packages to be suitable to install any other Fedora package. Additionally, it
# supports being cross-bootstrapped. Meaning, you can instantiate the image for
# other foreign architectures. Since this requires binfmt-qemu emulation, the
# base package includes qemu-user-static. This is obsolete with newer kernels
# (the 'F' binfmt-misc flag first appeared in linux-v4.8), but needed for
# compatibility with older systems.
#
# Be aware that this Dockerfile does not create the final image! On the
# contrary, it bootstraps the 'fedora-base' image into
# /var/lib/cherryimages/sysroot and provides a tarball of that directory as
# /var/lib/cherryimages/sysroot.tar. You should copy it out of there and import
# it into docker to get your new 'fedora-base' image. This is needed because
# the 'COPY' docker-command does not support overriding /proc and friends in
# live images. Furthermore, it strips ownership from files, which is really
# unfortunate. Hence, you need the intermediate image. Use 'docker import' to
# get a fresh base image from the sysroot.tar file.
#
# Options:
#
#     CHERRY_FEDORA_ARCH: Fedora architecture to build.
#
#     CHERRY_FEDORA_RELEASE: The fedora release to build.
#

FROM cherrypick/cherryimages-source AS source

#
# Setup Bootstrap
#
# We use the official fedora images to bootstrap our image. We fully rely on
# these to be kept up-to-date. We don't update them manually. This speeds up
# the build considerably.
#

FROM fedora AS bootstrap

ARG CHERRY_FEDORA_ARCH
ARG CHERRY_FEDORA_RELEASE

#
# Import Qemu
#
# The dnf post-install scriptlets might invoke random binaries. Hence, we need
# a qemu interpreter in case we bootstrap foreign architectures.
# We rely on the caller to use proper qemu integration with kernel binfmts. In
# case the kernel does not support the 'F' flag, we provide a statically linked
# interpreter in the image itself.
#

COPY --from=source "/var/lib/cherryimages/qemu/" "/usr/bin/"

#
# Bootstrap Fedora
#
# We bootstrap an entire distro into /var/lib/cherryimages/sysroot. Prepare the
# directory and then invoke dnf to bootstrap into it.
#

RUN mkdir -p /var/lib/cherryimages/sysroot

# Fedora's qemu-user-static is broken on i386... Use our own.
COPY --from=source "/var/lib/cherryimages/qemu/" "/var/lib/cherryimages/sysroot/usr/bin/"

RUN dnf \
                -y \
                -v \
                --nodocs \
                --repo=fedora \
                --repo=updates \
                --forcearch="${CHERRY_FEDORA_ARCH}" \
                --releasever="${CHERRY_FEDORA_RELEASE}" \
                --installroot=/var/lib/cherryimages/sysroot \
                --setopt=install_weak_deps=False \
                install \
                        bash \
                        ca-certificates \
                        dnf \
                        fedora-release \
                        tar \
        && dnf \
                --installroot=/var/lib/cherryimages/sysroot \
                clean all

# Fedora `dnf` is broken for armv7hl
RUN sed \
        -i \
        "s/'armv7hnl', 'armv8hl'/'armv7hnl', 'armv7hcnl', 'armv8hl'/" \
        /var/lib/cherryimages/sysroot/usr/lib/python3.7/site-packages/dnf/rpm/__init__.py

RUN tar \
        -p \
        --acls \
        --xattrs \
        --numeric-owner \
        -cf "/var/lib/cherryimages/sysroot.tar" \
        -C "/var/lib/cherryimages/sysroot/" \
        .
