# Pi Coding Agent — Docker Template

Run pi coding agent inside Docker. Mount your project. Safe. Isolated.

## Setup

### 1. Prepare your project

Put your code in `./project/` (or change the volume path in `docker-compose.yml`).

```
pi-docker/
├── Dockerfile
├── docker-compose.yml
├── README.md
└── project/          ← your code goes here
    ├── src/
    ├── package.json
    └── ...
```

### 2. Start the agent

```bash
docker compose up --build
```

Agent runs. Interactive. Type commands.

### 3. Run commands directly (non-interactive)

```bash
# One-shot command
docker compose run --rm pi-agent pi "refactor auth module"

# Shell access
docker compose exec pi-agent bash
```

## Safety

- **Non-root user** — runs as `piuser` (uid 1000)
- **Volume mount** — your project lives on host. Container can read/write
- **Persistent cache** — `pi-cache` volume stores pi config between runs
- **No privileged mode** — no extra capabilities needed

## Docker run (no compose)

Run directly with Docker:

```bash
 docker build . -t pi-agent:latest

 docker run -it --rm \
  -v $(pwd)/project:/home/piuser/workspace:rw \
  -e PI_PROJECT_DIR=/home/piuser/workspace \
  -w /home/piuser/workspace \
  pi-agent:latest
```


**Build first:**

```bash
docker build -t pi-agent:latest .
```

## Customization

### Change project path

Edit `docker-compose.yml` volume line:

```yaml
volumes:
  - /path/to/your/project:/home/piuser/workspace:rw
```

### Add tools

Edit `Dockerfile`:

```dockerfile
RUN apt-get install -y --no-install-recommends <your-tools>
```

### Change Node version

Change base image:

```dockerfile
FROM node:24-slim
```

## Troubleshooting

**Permission denied on mounted files**

Match host user uid to container uid (1000):

```bash
# Check your uid
id -u

# If not 1000, edit Dockerfile:
# RUN useradd -m -u <YOUR_UID> -g piuser piuser
```

**Agent not found**

```bash
docker compose run --rm pi-agent which pi
```

**Cache too large**

```bash
docker volume rm pi-docker_pi-cache
```


## LOCAL LLM

You can call your local llm using `host.docker.internal`. 