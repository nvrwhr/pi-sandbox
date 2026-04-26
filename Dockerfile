FROM node:24-slim

RUN apt-get update && apt-get install -y ca-certificates git \
    && update-ca-certificates

RUN apt-get install -y --no-install-recommends \
    bash curl wget \
    && rm -rf /var/lib/apt/lists/*

# # Create piuser
# RUN groupadd -g 2000 piuser \
#   && useradd -m -u 2000 -g piuser -s /bin/bash piuser \
#   && mkdir -p /home/piuser/.pi/agent \
#   && chown -R piuser:piuser /home/piuser/.pi

RUN npm install -g @mariozechner/pi-coding-agent

# Inject config files via build args (pass file contents as base64)
ARG MODELS_JSON_B64
ARG AUTH_JSON_B64

RUN mkdir -p /root/.pi/agent

RUN echo "$MODELS_JSON_B64" | base64 -d > /root/.pi/agent/models.json; 
RUN echo "$AUTH_JSON_B64" | base64 -d > /root/.pi/agent/auth.json; 

# RUN chown piuser:piuser /home/piuser/.pi/agent/auth.json; 
# RUN chown piuser:piuser /home/piuser/.pi/agent/models.json; 

# COPY --chown=piuser:piuser replace-localhost.js /home/piuser/replace-localhost.js
COPY replace-localhost.js /root/replace-localhost.js
RUN node /root/replace-localhost.js && rm /root/replace-localhost.js

RUN	pi install npm:pi-gitnexus

WORKDIR /root
RUN npx skills add JuliusBrussee/caveman -a pi --all

WORKDIR /root/workspace



CMD ["bash"]
