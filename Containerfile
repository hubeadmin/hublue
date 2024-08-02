ARG SB_VERSION=40
FROM quay.io/fedora/fedora-silverblue:${SB_VERSION}

# Enable video for streaming in Firefox
RUN rpm-ostree override remove noopenh264 \
    --install openh264 \
    --install gstreamer1-plugin-openh264 \
    --install mozilla-openh264

# My extra packages
RUN rpm-ostree install awscli2 \
    git \
    htop \
    make \
    python3-devel \
    python3-flake8 \
    python3-pip \
    yamllint \
    yq \
    bat \
    cargo \
    chkconfig \
    fira-code-fonts \
    gcc \
    gnome-tweaks \
    ipa-admintools \
    ipa-client \
    krb5-devel \
    libvirt  \
    lxrandr  \
    make  \
    neovim \
    nodejs \
    npm  \
    openssh-askpass \
    openssl \
    pipx \
    podman-compose \
    python3-koji-cli-plugins \
    python3.9 \
    ripgrep \
    tilix \
    zsh
