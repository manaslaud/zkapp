FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    git \
    curl \
    jq \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Set it as the default working directory
WORKDIR /workspace

# Default command
CMD [ "bash" ]
