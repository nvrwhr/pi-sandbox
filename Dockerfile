FROM node:24-slim

RUN apt-get update && apt-get install -y ca-certificates git \
    && update-ca-certificates

RUN apt-get install -y --no-install-recommends \
    bash curl wget \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g @mariozechner/pi-coding-agent

ARG MODELS_JSON_B64
ARG AUTH_JSON_B64

RUN mkdir -p /root/.pi/agent

RUN echo "$MODELS_JSON_B64" | base64 -d > /root/.pi/agent/models.json; 
RUN echo "$AUTH_JSON_B64" | base64 -d > /root/.pi/agent/auth.json; 

COPY replace-localhost.js /root/replace-localhost.js
RUN node /root/replace-localhost.js && rm /root/replace-localhost.js

RUN	pi install npm:pi-gitnexus

WORKDIR /root
RUN npx skills add JuliusBrussee/caveman -a pi --all

WORKDIR /root/workspace

CMD ["bash"]
