FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

# LABEL maintainer="github@xX-MrN0b0dy-Xx" \
#       org.opencontainers.image.authors="github@xX-MrN0b0dy-Xx" \
#       org.opencontainers.image.source="https://github.com/xX-MrN0b0dy-Xx/obsidian-remote" \
#       org.opencontainers.image.title="Obsidian MD with KasmVNC" \
#       org.opencontainers.image.description="Hosted Obsidian instance accessible via web browser through KasmVNC"

# Update and install extra packages
RUN echo "**** install packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends curl libgtk-3-0 libnotify4 libatspi2.0-0 libsecret-1-0 libnss3 desktop-file-utils fonts-noto-color-emoji git ssh-askpass && \
    apt-get autoclean && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# Download and install Obsidian
RUN echo "**** Get latest Obsidian release ****" && \
    OBSIDIAN_VERSION=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/^v//') && \
    echo "Latest version: $OBSIDIAN_VERSION" && \
    echo "" && \
    echo "**** Download and Install Obsidian ****" && \
    curl -L -o obsidian.deb "https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/obsidian_${OBSIDIAN_VERSION}_amd64.deb" && \
    dpkg -i obsidian.deb && \
    rm obsidian.deb

# Environment variables
ENV CUSTOM_PORT="8080" \
    CUSTOM_HTTPS_PORT="8443" \
    CUSTOM_USER="" \
    PASSWORD="" \
    SUBFOLDER="" \
    TITLE="Obsidian v${OBSIDIAN_VERSION}" \
    FM_HOME="/vaults"

# Add local files
COPY root/ /

# Expose ports and volumes
EXPOSE 8080 8443
VOLUME ["/config","/vaults"]

# Define a healthcheck
HEALTHCHECK CMD /bin/sh -c 'if [ -z "$CUSTOM_USER" ] || [ -z "$PASSWORD" ]; then curl --fail http://localhost:"$CUSTOM_PORT"/ || exit 1; else curl --fail --user "$CUSTOM_USER:$PASSWORD" http://localhost:"$CUSTOM_PORT"/ || exit 1; fi'
