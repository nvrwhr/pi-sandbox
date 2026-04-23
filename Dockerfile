FROM node:24-slim

RUN apt-get update && apt-get install -y ca-certificates git \
    && update-ca-certificates

RUN apt-get install -y --no-install-recommends \
     bash curl wget \
    && rm -rf /var/lib/apt/lists/*

# Create piuser
RUN groupadd -g 2000 piuser \
  && useradd -m -u 2000 -g piuser -s /bin/bash piuser \
  && mkdir -p /home/piuser/.pi/agent \
  && chown -R piuser:piuser /home/piuser/.pi


# Inject config files via build args (pass file contents as base64)
ARG MODELS_JSON_B64
ARG AUTH_JSON_B64


RUN npm install -g @mariozechner/pi-coding-agent
RUN npx skills add JuliusBrussee/caveman -a pi --all

RUN echo "$MODELS_JSON_B64" | base64 -d > /home/piuser/.pi/agent/models.json; exit 0
RUN echo "$AUTH_JSON_B64" | base64 -d > /home/piuser/.pi/agent/auth.json; exit 0
    
RUN chown piuser:piuser /home/piuser/.pi/agent/auth.json; exit 0
RUN chown piuser:piuser /home/piuser/.pi/agent/models.json; exit 0

COPY --chown=piuser:piuser replace-localhost.js /home/piuser/replace-localhost.js
RUN node /home/piuser/replace-localhost.js

USER piuser
WORKDIR /home/piuser/

CMD ["bash"]
