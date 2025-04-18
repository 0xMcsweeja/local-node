# Ethereum Full Node Stack
      ┌───────────────────────────────────────────────┐
      │ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄  │
      │ ████████████████████████████████████████████▌ │
      │ ██┌──────────────────────────────────────┐███ │
      │ ██│                                      │███ │
      │ ██│  Ξ 🟢 ETHEREUM MAINNET NODE  Ξ  🟢  │███ │
      │ ██│                                      │███ │
      │ ██│  » Status   : SYNCED                 │███ │
      │ ██│  » Client   : GETH + LIGHTHOUSE      │███ │
      │ ██│  » Mode     : FULL / BEACON          │███ │
      │ ██│  » RPC      : ENABLED (localhost)    │███ │
      │ ██│  » P2P      : 30303 TCP/UDP          │███ │
      │ ██│                                      │███ │
      │ ██└──────────────────────────────────────┘███ │
      │ ████████████████████████████████████████████▌ │
      │ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀  │
      └───────────────────────────────────────────────┘
               │
               │───[🌐 NODE INFO]
               │     ├─ Network ID  : 1 (Mainnet)
               │     └─ Sync Mode   : Snap
               │
               │───[🛰️ CONNECTIONS]
               │     ├─ Peers       : x active
               │     ├─ Latency     : x ms avg
               │     └─ Region      : AU-East
               │
               └───[🛠️ TOOLCHAIN]
                     ├─ Docker Compose / WSL2
                     ├─ Monitoring via Prometheus
                     └─ Grafana Dashboards Enabled

A minimal, production-ready Ethereum node setup using Docker Compose. Combines Geth (EL) and Lighthouse (CL) for a complete post-merge node.

> Tested on Windows 10 Home with WSL 2 (Ubuntu 22.04) and Docker Desktop 4.30

## Components

Post-merge Ethereum requires two client layers working together:

- **Execution Layer** (Geth): Handles state, transactions, and RPC
- **Consensus Layer** (Lighthouse): Manages consensus and block finality

Running both gives you sovereign access to the network without trusting third parties.

## Hardware Requirements

- 300+ GB fast SSD storage
- 8+ GB RAM (12+ GB recommended)
- Stable internet connection

## Quick Start

```bash
# Clone and set up
git clone https://github.com/<your-handle>/ethereum-node-stack.git
cd ethereum-node-stack
cp .env.example .env

# Generate JWT secret for client authentication
./scripts/gen-jwt-secret.sh  # On Windows: use scripts\gen-jwt-secret.sh

# Launch the stack
docker compose pull
docker compose up -d

# Watch the sync progress
docker compose logs -f
```

First sync requires ~112 GB (100 GB Geth + 12 GB Lighthouse). Plan accordingly.

## Key Components

- **docker-compose.yml**: Orchestrates both clients with proper networking
- **.env**: Controls client versions and port mappings
- **scripts/**: Contains maintenance utilities:
  - `gen-jwt-secret.sh`: Creates authentication token
  - `prune-geth.sh`: Reduces Geth's disk usage
  - `backup.sh`: Creates archives of chain data

Make scripts executable:
- On Linux/macOS: `chmod +x scripts/*.sh`
- On Windows: `icacls scripts\*.sh /grant Everyone:RX`

## Maintenance

Common tasks to keep your node healthy:

```bash
# Check sync status
curl -X POST http://localhost:8545 -H "Content-Type: application/json" \
     --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}'

# Prune Geth to save disk space (run weekly)
./scripts/prune-geth.sh

# Create full backup (offline process)
./scripts/backup.sh
```

## Windows Setup

1. Enable virtualization in BIOS
2. Install WSL 2 via PowerShell (as admin):
   ```powershell
   wsl --install -d Ubuntu-22.04
   ```
3. Install Docker Desktop with WSL 2 integration
4. Configure WSL resources in `%UserProfile%\.wslconfig`:
   ```ini
   [wsl2]
   memory=12GB
   processors=8
   ```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Docker won't start | Check disk space (`df -h`), need 300+ GB |
| Authentication errors | Verify `jwtsecret/jwt.hex` permissions |
| Slow sync | Check internet connection and other bandwidth usage |
| Memory errors | Increase allocation in `.wslconfig` |
| Client connection issues | Ensure Geth is running before Lighthouse |
| High disk usage | Run `./scripts/prune-geth.sh` |

## References

* [Geth Documentation](https://geth.ethereum.org/docs)
* [Lighthouse Documentation](https://lighthouse-book.sigmaprime.io/)
* [Ethereum Node Requirements](https://ethereum.org/en/run-a-node/)

## License

MIT

