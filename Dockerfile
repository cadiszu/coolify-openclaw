# Use the official Node 22 Bookworm image as base
FROM node:22-bookworm-slim

# Set labels for Coolify and metadata
LABEL maintainer="YourName"
LABEL description="OpenClaw Gateway for Coolify"

# Install system dependencies needed for building and running skills
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    unzip \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Install Bun for high-performance execution
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

# Set working directory
WORKDIR /app

# Clone the official repo (using the stable main branch)
RUN git clone --depth 1 https://github.com/openclaw/openclaw.git .

# Install dependencies using pnpm (standard for OpenClaw)
RUN corepack enable && pnpm install --frozen-lockfile

# Build the application
RUN pnpm build
RUN pnpm ui:build

# Create a non-root user for security
RUN groupadd -r openclaw && useradd -r -g openclaw -d /home/openclaw openclaw
RUN mkdir -p /home/openclaw/.openclaw /home/openclaw/workspace \
    && chown -R openclaw:openclaw /home/openclaw /app

# Switch to the non-root user
USER openclaw
WORKDIR /home/openclaw

# Expose the default OpenClaw port
EXPOSE 18789

# Set Production environment
ENV NODE_ENV=production
ENV PATH="/app/node_modules/.bin:${PATH}"

# Start the Gateway
ENTRYPOINT ["node", "/app/dist/index.js"]
CMD ["gateway", "run"]
