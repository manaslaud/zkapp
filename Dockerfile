FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
  git \
  curl \
  jq \
  && apt clean && rm -rf /var/lib/apt/lists/*

# Default command
CMD [ "bash" ]
