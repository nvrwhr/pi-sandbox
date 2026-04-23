FROM node:24-slim

RUN apt-get update && apt-get install -y ca-certificates git \
    && update-ca-certificates


RUN apt-get install -y --no-install-recommends \
     bash curl wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/piuser

# Install pi globally
RUN npm install -g @mariozechner/pi-coding-agent
RUN npx skills add JuliusBrussee/caveman -a pi --all

# Default: run agent pi
CMD ["bash"] 
