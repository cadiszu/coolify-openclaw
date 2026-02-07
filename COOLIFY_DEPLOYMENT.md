# OpenClaw Coolify Deployment Guide

## Step-by-Step Deployment Instructions

### Step 1: Prepare Your Git Repository

1. **Create a new repository** on GitHub, GitLab, or your preferred Git provider

2. **Clone the repository** locally:
   ```bash
   git clone <your-repo-url>
   cd <your-repo-name>
   ```

3. **Add the deployment files**:
   - Copy `Dockerfile`
   - Copy `docker-compose.yml`
   - Copy `.env.example`
   - Copy `.dockerignore`
   - Copy `README.md`

4. **Commit and push**:
   ```bash
   git add .
   git commit -m "Initial OpenClaw deployment setup"
   git push origin main
   ```

### Step 2: Connect to Coolify

1. **Login to your Coolify dashboard**
   - URL: `https://your-coolify-instance.com`

2. **Add a new resource**:
   - Click "+ New" → "Resource"
   - Select "Git Repository"

3. **Connect your repository**:
   - Select your Git provider (GitHub/GitLab/Gitea)
   - Authenticate if needed
   - Select your repository
   - Choose branch: `main`

### Step 3: Configure the Application

1. **Application Type**:
   - Build Pack: `Docker Compose`
   - Port: `18789`

2. **Build Configuration**:
   - Docker Compose Location: `docker-compose.yml`
   - Dockerfile Location: `Dockerfile`

3. **Domains**:
   - Add your domain or use Coolify's generated subdomain
   - Example: `openclaw.yourdomain.com`
   - Coolify will automatically provision SSL/TLS

### Step 4: Set Environment Variables

In Coolify, go to "Environment Variables" and add:

#### Required Variables:

```env
OPENCLAW_GATEWAY_TOKEN
```
Generate with: `openssl rand -hex 32`

#### AI Provider (choose one):

**For Claude/Anthropic:**
```env
CLAUDE_AI_SESSION_KEY=sk-ant-...
```

**For OpenAI:**
```env
OPENAI_API_KEY=sk-...
```

**For OpenRouter (multiple models):**
```env
OPENROUTER_API_KEY=sk-or-v1-...
```

#### Optional Messaging Platforms:

**Telegram:**
```env
TELEGRAM_BOT_TOKEN=123456789:ABCdefGHIjklMNOpqrsTUVwxyz
```

**Discord:**
```env
DISCORD_BOT_TOKEN=MTIzNDU2Nzg5MDEyMzQ1Njc4OQ.Gxxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxx
```

**Slack:**
```env
SLACK_BOT_TOKEN=xoxb-...
SLACK_APP_TOKEN=xapp-...
```

### Step 5: Configure Ports

1. **Gateway Port**: `18789`
   - Protocol: HTTP
   - Publicly accessible: Yes
   - This is the main dashboard and API

2. **Bridge Port**: `18790` (Optional)
   - Protocol: HTTP
   - Publicly accessible: No (internal only)
   - Used for device pairing

### Step 6: Storage (Volumes)

Coolify automatically creates and manages volumes:

- `openclaw-config`: Configuration and credentials
- `openclaw-workspace`: Agent workspace and files

**No additional configuration needed!**

### Step 7: Deploy

1. Click **"Deploy"** button
2. Monitor build logs in real-time
3. First deployment takes 10-15 minutes (building dependencies)
4. Subsequent deployments are faster (~2-3 minutes)

### Step 8: Initial Configuration

After successful deployment:

1. **Access the Terminal** in Coolify:
   - Go to your resource
   - Click "Terminal" tab
   - Select `openclaw-gateway` container

2. **Run the onboarding wizard**:
   ```bash
   node dist/index.js onboard --no-install-daemon
   ```

3. **Follow the prompts**:
   - Select gateway mode: `Remote`
   - Gateway bind: `lan` (already set)
   - Gateway port: `18789` (already set)
   - Model provider: Choose your configured provider
   - Skip daemon installation (already running in Docker)

4. **Access the Dashboard**:
   - URL: `https://your-domain.com/?token=YOUR_GATEWAY_TOKEN`
   - Replace with your actual domain and token

## Advanced Configuration

### Health Checks

The docker-compose.yml includes health checks:
- Endpoint: `/health`
- Interval: 30 seconds
- Timeout: 10 seconds
- Coolify monitors this automatically

### Scaling Considerations

**Single Instance (Recommended):**
- OpenClaw is designed to run as a single instance
- Multiple instances can conflict with session management

**Resource Allocation:**
- Minimum: 2GB RAM, 2 CPU cores
- Recommended: 4GB RAM, 4 CPU cores
- Production: 8GB RAM, 4-8 CPU cores

### Backup Strategy

**What to Backup:**
1. Volume: `openclaw-config` (contains credentials and config)
2. Volume: `openclaw-workspace` (contains agent files)
3. Environment variables (export from Coolify)

**Backup Methods:**
1. **Coolify Backups**: Enable automatic backups in settings
2. **Manual Volume Backup**:
   ```bash
   docker run --rm -v openclaw-config:/data -v $(pwd):/backup alpine tar czf /backup/openclaw-config.tar.gz -C /data .
   ```

### Custom Domain Setup

1. **Add domain in Coolify**:
   - Go to your resource
   - Click "Domains"
   - Add your domain: `openclaw.yourdomain.com`

2. **Configure DNS**:
   - Add A record pointing to your Coolify server IP
   - Or CNAME to Coolify's domain

3. **SSL/TLS**:
   - Coolify automatically provisions Let's Encrypt certificates
   - Force HTTPS is enabled by default

## Monitoring and Logs

### Viewing Logs

**In Coolify:**
1. Go to your resource
2. Click "Logs" tab
3. Select container: `openclaw-gateway`

**Via Docker:**
```bash
docker logs -f openclaw-gateway
```

### Key Metrics to Monitor

1. **Memory Usage**: Should stay under 2-3GB normally
2. **CPU Usage**: Spikes during AI operations
3. **Disk Usage**: Workspace grows with agent activity
4. **Network**: Outbound to AI providers

### Alerts

Configure in Coolify:
1. Resource → Settings → Notifications
2. Add Discord/Slack webhook
3. Enable alerts for:
   - Container crashes
   - High resource usage
   - Deployment failures

## Maintenance

### Updating OpenClaw

1. **Check for updates**:
   - Watch [OpenClaw releases](https://github.com/openclaw/openclaw/releases)

2. **Update method**:
   - Click "Redeploy" in Coolify
   - Or push to Git and auto-deploy triggers

3. **Rollback if needed**:
   - Coolify keeps deployment history
   - Click "Deployments" → Select previous → "Redeploy"

### Regular Tasks

**Weekly:**
- Review logs for errors
- Check disk space usage
- Monitor API costs

**Monthly:**
- Update to latest OpenClaw version
- Review and rotate gateway token
- Backup volumes
- Check for security updates

## Troubleshooting

### Common Issues

**1. Gateway Won't Start**
```bash
# Check logs
docker logs openclaw-gateway

# Common causes:
# - Missing OPENCLAW_GATEWAY_TOKEN
# - Port already in use
# - Insufficient memory
```

**2. Can't Access Dashboard**
```
Error: Secure context required
Solution: Access via HTTPS or localhost
Ensure: Coolify SSL is enabled
```

**3. AI Provider Connection Failed**
```
# Verify API keys
docker exec openclaw-gateway env | grep API_KEY

# Test connectivity
docker exec openclaw-gateway curl -I https://api.openai.com
```

**4. Permission Denied Errors**
```bash
# Check volume ownership
docker exec openclaw-gateway ls -la /home/node/.openclaw

# Should be owned by node (UID 1000)
# Fix if needed (from Coolify server):
docker run --rm -v openclaw-config:/data alpine chown -R 1000:1000 /data
```

### Getting Help

1. **Coolify Support**:
   - Discord: https://discord.gg/coolify
   - Docs: https://coolify.io/docs

2. **OpenClaw Support**:
   - Discord: https://discord.gg/clawd
   - GitHub: https://github.com/openclaw/openclaw/issues
   - Docs: https://docs.openclaw.ai

3. **Community**:
   - Reddit: r/selfhosted
   - Hacker News: Check for OpenClaw discussions

## Security Best Practices

1. ✅ **Use strong gateway token** (32+ characters)
2. ✅ **Enable Coolify authentication**
3. ✅ **Use HTTPS only** (Coolify default)
4. ✅ **Restrict network access** via firewall
5. ✅ **Regular backups** of volumes
6. ✅ **Monitor logs** for suspicious activity
7. ✅ **Review messaging platform permissions**
8. ✅ **Use sandbox mode** for multi-user setups
9. ✅ **Rotate credentials** regularly
10. ✅ **Keep updated** to latest version

## Cost Considerations

### Hosting Costs
- VPS: $5-20/month (depending on specs)
- Coolify: Free (self-hosted)
- Domain: $10-15/year

### AI API Costs (Variable)
- OpenAI GPT-4: ~$0.03-0.06 per 1K tokens
- Claude: ~$0.015-0.075 per 1K tokens
- Heavy usage: $50-200/month
- Light usage: $5-20/month

**💡 Tip**: Start with ChatGPT subscription ($20/month) to cap costs while testing.

## Next Steps

After successful deployment:

1. ✅ Configure your preferred messaging platform
2. ✅ Test basic commands
3. ✅ Set up automations/skills
4. ✅ Configure backup schedule
5. ✅ Join OpenClaw community
6. ✅ Read advanced docs

---

**Happy Deploying! 🦞**
