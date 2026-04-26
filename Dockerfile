# FROM node:24-slim

# RUN apt update && apt install -y ca-certificates git \
#     && update-ca-certificates

# RUN apt install -y --no-install-recommends \
#     build-essential software-properties-common \
#     cmake gcc g++ python3 ninja-build ccache \
#     bash curl wget 

# RUN rm -rf /var/lib/apt/lists/*

# RUN npm i -g @mariozechner/pi-coding-agent
# RUN curl -s https://install.ladybugdb.com | bash

# ARG MODELS_JSON_B64
# ARG AUTH_JSON_B64

# RUN mkdir -p /root/.pi/agent

# RUN echo "$MODELS_JSON_B64" | base64 -d > /root/.pi/agent/models.json; 
# RUN echo "$AUTH_JSON_B64" | base64 -d > /root/.pi/agent/auth.json; 

# COPY replace-localhost.js /root/replace-localhost.js
# RUN node /root/replace-localhost.js && rm /root/replace-localhost.js

# RUN	pi install npm:pi-gitnexus
# RUN npm i -g gitnexus

# WORKDIR /root
# RUN npx skills add JuliusBrussee/caveman -a pi --all


# WORKDIR /root/workspace

# CMD ["bash"]



FROM ubuntu:24.04

RUN apt update && apt install -y ca-certificates git \
    && update-ca-certificates

RUN apt install -y --no-install-recommends \
    build-essential software-properties-common \
    cmake gcc g++ python3 ninja-build ccache \
    bash curl wget 

RUN rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://nodejs.org/dist/v24.15.0/node-v24.15.0-linux-x64.tar.xz | tar -xJ -C /usr/local --strip-components=1 \
    && npm cache clean --force

RUN npm i -g @mariozechner/pi-coding-agent
RUN curl -s https://install.ladybugdb.com | bash

ARG MODELS_JSON_B64
ARG AUTH_JSON_B64

RUN mkdir -p /root/.pi/agent

RUN echo "$MODELS_JSON_B64" | base64 -d > /root/.pi/agent/models.json; 
RUN echo "$AUTH_JSON_B64" | base64 -d > /root/.pi/agent/auth.json; 

COPY replace-localhost.js /root/replace-localhost.js
RUN node /root/replace-localhost.js && rm /root/replace-localhost.js

RUN	pi install npm:pi-gitnexus
RUN npm i -g gitnexus

WORKDIR /root
RUN npx skills add JuliusBrussee/caveman -a pi --all


WORKDIR /root/workspace

CMD ["bash"]
