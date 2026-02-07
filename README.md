# OpenClaw Deployment for Coolify

This repository contains the necessary files to deploy OpenClaw on Coolify, a self-hosted PaaS platform.

## 📋 Prerequisites

- Coolify instance (v4.0+)
- GitHub/GitLab repository with these files
- At least 2GB RAM (4GB recommended)
- 10GB+ disk space

## 🚀 Quick Start

### 1. Prepare Your Repository

1. Create a new Git repository
2. Add these files to your repository:
   - `Dockerfile`
   - `docker-compose.yml`
   - `.env.example` (optional)

3. Commit and push to your Git provider

### 2. Deploy to Coolify

1. **Login to Coolify Dashboard**

2. **Create New Resource**
   - Click "New Resource" → "Docker Compose"
   - Select your Git provider and repository
   - Choose the branch (usually `main`)

3. **Configure Build Settings**
   - Build Pack: `Docker Compose`
   - Dockerfile: `Dockerfile`
   - Docker Compose File: `docker-compose.yml`

4. **Set Environment Variables** (Important!)

   Required variables:
   ```env
   OPENCLAW_GATEWAY_TOKEN=your-secure-random-token-here
   ```

   AI Provider (choose one or more):
   ```env
   # For Claude (Anthropic)
   CLAUDE_AI_SESSION_KEY=your-claude-session-key
   
   # For OpenAI
   OPENAI_API_KEY=your-openai-api-key
   ```

   Messaging Platforms (optional):
   ```env
   # Telegram
   TELEGRAM_BOT_TOKEN=your-telegram-bot-token
   
   # Discord
   DISCORD_BOT_TOKEN=your-discord-bot-token
   
   # Slack
   SLACK_BOT_TOKEN=your-slack-bot-token
   SLACK_APP_TOKEN=your-slack-app-token
   ```

5. **Configure Ports**
   - Add port `18789` for Gateway API/Dashboard
   - Add port `18790` for Bridge (optional)

6. **Deploy!**
   - Click "Deploy"
   - Wait for the build to complete (first build takes 10-15 minutes)

### 3. Access OpenClaw

After deployment:
- Gateway Dashboard: `https://your-domain.com:18789/?token=YOUR_GATEWAY_TOKEN`
- Or use the domain Coolify assigns to port 18789

## 🔧 Configuration

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `OPENCLAW_GATEWAY_TOKEN` | **Yes** | Secure token for dashboard access (generate random) |
| `OPENCLAW_GATEWAY_BIND` | No | Bind address (default: `lan`) |
| `OPENCLAW_GATEWAY_PORT` | No | Gateway port (default: `18789`) |
| `OPENCLAW_BRIDGE_PORT` | No | Bridge port (default: `18790`) |
| `CLAUDE_AI_SESSION_KEY` | No | Claude API session key |
| `OPENAI_API_KEY` | No | OpenAI API key |
| `TELEGRAM_BOT_TOKEN` | No | Telegram bot token |
| `DISCORD_BOT_TOKEN` | No | Discord bot token |

### Generating a Secure Token

```bash
# Linux/Mac
openssl rand -hex 32

# Or use any password generator
```

## 📦 Volume Persistence

Coolify automatically handles volume persistence:
- `openclaw-config`: Stores configuration and session data
- `openclaw-workspace`: Agent workspace and files

## 🔐 Security Best Practices

1. **Always use HTTPS** - Coolify provides this automatically
2. **Strong Gateway Token** - Use a randomly generated 32+ character token
3. **Restrict Access** - Use Coolify's built-in authentication
4. **Regular Updates** - Redeploy when new OpenClaw versions are released
5. **Review Permissions** - Be cautious with messaging platform integrations

## 🛠️ Initial Setup

After first deployment, you need to configure OpenClaw:

### Option 1: Using Coolify Terminal

1. Go to your resource in Coolify
2. Click "Terminal"
3. Run:
   ```bash
   node dist/index.js onboard --no-install-daemon
   ```

### Option 2: Using Docker Exec (from server)

```bash
docker exec -it openclaw-gateway node dist/index.js onboard --no-install-daemon
```

Follow the interactive wizard to:
- Select your AI model provider
- Configure authentication
- Set up messaging channels

## 📱 Connecting Messaging Platforms

### Telegram

1. Create a bot via [@BotFather](https://t.me/botfather)
2. Get your bot token
3. Add `TELEGRAM_BOT_TOKEN` to Coolify environment variables
4. Redeploy
5. Message your bot to pair:
   ```bash
   docker exec -it openclaw-gateway node dist/index.js pairing approve telegram <CODE>
   ```

### Discord

1. Create a Discord application at [Discord Developer Portal](https://discord.com/developers/applications)
2. Create a bot and get the token
3. Add `DISCORD_BOT_TOKEN` to environment variables
4. Redeploy

### WhatsApp

WhatsApp requires additional setup. See [OpenClaw WhatsApp Documentation](https://docs.openclaw.ai/channels/whatsapp)

## 🔄 Updating OpenClaw

To update to the latest version:

1. In Coolify, go to your resource
2. Click "Redeploy"
3. Wait for the new build to complete

Coolify will automatically pull the latest code and rebuild.

## 🐛 Troubleshooting

### Gateway Won't Start

- Check Coolify logs for error messages
- Ensure `OPENCLAW_GATEWAY_TOKEN` is set
- Verify ports 18789 and 18790 are not in use

### Can't Access Dashboard

- Verify port 18789 is exposed in Coolify
- Check the gateway token in the URL matches your environment variable
- Ensure HTTPS is configured (required for secure context)

### Permission Errors

The container runs as user `node` (UID 1000). If you encounter permission issues:
- Ensure Coolify volumes have proper permissions
- Check container logs: `docker logs openclaw-gateway`

### Out of Memory

- Increase memory allocation in Coolify settings
- Recommended: 4GB RAM minimum for production

## 📚 Additional Resources

- [OpenClaw Official Documentation](https://docs.openclaw.ai)
- [OpenClaw GitHub Repository](https://github.com/openclaw/openclaw)
- [Coolify Documentation](https://coolify.io/docs)

## 🆘 Support

- OpenClaw Discord: [Join Here](https://discord.gg/clawd)
- Coolify Discord: [Join Here](https://discord.gg/coolify)
- GitHub Issues: [Report Here](https://github.com/openclaw/openclaw/issues)

## ⚠️ Important Notes

1. **Security**: OpenClaw has broad permissions. Review [security documentation](https://docs.openclaw.ai/gateway/security)
2. **Costs**: AI API usage can be expensive. Monitor your usage!
3. **Privacy**: Messages and data are processed by third-party AI providers
4. **Production Use**: Consider running in sandbox mode for non-main sessions

## 📝 License

OpenClaw is licensed under MIT License. See the [official repository](https://github.com/openclaw/openclaw) for details.
