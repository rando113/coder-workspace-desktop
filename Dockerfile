# Dockerfile
FROM codercom/enterprise-desktop:ubuntu

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    jq \
    ca-certificates \
    iputils-ping \
    net-tools \
    openjdk-11-jdk \
    openjdk-11-source \
    python3 \
    python3-pip \
    vim \
    less \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Google Chrome
RUN apt-get update && \
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-linux-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && apt-get install -y google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

COPY *.desktop /usr/share/applications

# Pre-install JetBrains Intellij and PyCharm
RUN mkdir -p /opt/jetbrains && \
    wget -q https://download.jetbrains.com/idea/code-with-me/backend/jetbrains-clients-downloader-linux-x86_64-1867.tar.gz && \
    tar -xzf jetbrains-clients-downloader-linux-x86_64-1867.tar.gz && \
    rm -f jetbrains-clients-downloader-linux-x86_64-1867.tar.gz && \
    ./jetbrains-clients-downloader-linux-x86_64-1867/bin/jetbrains-clients-downloader \
      --products-filter IC \
      --platforms-filter linux-x64 \
      --build-filter 252.28539.33 --verbose \
      --download-backends /opt/jetbrains && \
    tar -C /opt/jetbrains/backends/IC/ -xzf /opt/jetbrains/backends/IC/ideaIC-2025.2.6.1.tar.gz && \
    rm -f /opt/jetbrains/backends/IC/ideaIC-2025.2.6.1.tar.gz && \
    ./jetbrains-clients-downloader-linux-x86_64-1867/bin/jetbrains-clients-downloader \
      --products-filter PY \
      --platforms-filter linux-x64 \
      --build-filter 251.25410.122 --verbose \
      --download-backends /opt/jetbrains && \
    tar -C /opt/jetbrains/backends/PY/ -xzf /opt/jetbrains/backends/PY/pycharm-2025.1.1.tar.gz && \
    rm -f /opt/jetbrains/backends/PY/pycharm-2025.1.1.tar.gz && \
    rm -rf jetbrains-clients-downloader-linux-x86_64-1867

# Claude Code via apt repo (Debian/Ubuntu)
RUN set -eux; \
  apt-get update && apt-get install -y --no-install-recommends ca-certificates curl gnupg npm openssh-server; \
  install -d -m 0755 /etc/apt/keyrings; \
  curl -fsSL https://downloads.claude.ai/keys/claude-code.asc -o /etc/apt/keyrings/claude-code.asc; \
  echo "deb [signed-by=/etc/apt/keyrings/claude-code.asc] https://downloads.claude.ai/claude-code/apt/stable stable main" \
    > /etc/apt/sources.list.d/claude-code.list; \
  apt-get update; \
  apt-get install -y --no-install-recommends claude-code; \
  npm install -g @openai/codex; \
  rm -rf /var/lib/apt/lists/*

# Recommended GHCR label so the package links back to the repo automatically
# GitHub documents this as the easiest way to connect package <-> repo. :contentReference[oaicite:6]{index=6}
LABEL org.opencontainers.image.source="https://github.com/rando113/coder-workspace-desktop"

RUN chsh -s /bin/bash
ENV SHELL=/bin/bash

USER coder
WORKDIR /home/coder
