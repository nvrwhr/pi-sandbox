FROM node:24-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git bash curl wget \
    && rm -rf /var/lib/apt/lists/*

RUN corepack enable

# Create non-root user
RUN groupadd -g 1000 piuser && \
    useradd -m -u 1000 -g piuser -s /bin/bash piuser

USER piuser
WORKDIR /home/piuser

# Install pi globally
RUN npm install -g @mariozechner/pi-coding-agent
RUN npx skills add JuliusBrussee/caveman -a pi --all

# Default: run agent pi
CMD ["bash"] 
