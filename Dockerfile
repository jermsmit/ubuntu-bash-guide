# The lab: every example in the guide is run and screenshotted in this image.
FROM ubuntu:26.04

ARG FREEZE_VERSION=0.2.2
ARG DEBIAN_FRONTEND=noninteractive

# We deliberately do NOT install gawk or GNU coreutils: the lab should show the
# defaults a fresh Ubuntu 26.04 install gives you.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash-completion bats ca-certificates curl dnsutils file git htop \
      iproute2 iputils-ping jq less lsb-release make man-db nano \
      openssh-client procps psmisc ripgrep rsync shellcheck shfmt sudo \
      tmux tree unzip vim-tiny wget fd-find \
 && rm -rf /var/lib/apt/lists/*

# 'unminimize' restores man pages that Docker images normally strip out.
# It is best-effort: a failure here must not break the build.
RUN (yes | unminimize) || true

# freeze renders terminal output as SVG for the book's screenshots.
# pipefail so a failed download is not hidden by the pipe into tar.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN arch="$(dpkg --print-architecture)"; \
    case "$arch" in amd64) fa=x86_64 ;; arm64) fa=arm64 ;; *) echo "unsupported: $arch"; exit 1 ;; esac; \
    curl -fsSL "https://github.com/charmbracelet/freeze/releases/download/v${FREEZE_VERSION}/freeze_${FREEZE_VERSION}_Linux_${fa}.tar.gz" \
      | tar -xz -C /tmp \
 && install -m 0755 /tmp/freeze_*/freeze /usr/local/bin/freeze \
 && rm -rf /tmp/freeze_*

# A normal user with sudo, like a fresh Ubuntu install.
# (If the base image already has an 'ubuntu' user, that is fine: we add our own.)
RUN useradd -m -s /bin/bash learner \
 && echo 'learner ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/learner \
 && chmod 0440 /etc/sudoers.d/learner

USER learner
WORKDIR /home/learner
COPY --chown=learner:learner lab/ /home/learner/lab/
COPY --chown=learner:learner scripts/ /home/learner/guide/scripts/
COPY --chown=learner:learner src/ /home/learner/guide/src/

# Hand the whole repo in at runtime (see Makefile) when you want to edit it.
WORKDIR /home/learner/lab
CMD ["bash", "-l"]
