# Run a Full Ethereum Node (Geth + Lighthouse) with Docker Compose

> **Tested on Windows 10 Home, WSL 2 (Ubuntu 22.04) and Docker Desktop 4.30 – last checked 18 April 2025.**

---

## 1. Why you need two clients

Ethereum now splits work into two layers:

* **Execution Layer (EL)** – `geth` keeps the state, gossips transactions, and offers JSON‑RPC/Engine APIs.
* **Consensus Layer (CL)** – `lighthouse` follows Proof‑of‑Stake rules and finalises blocks.

Running both gives you a *full* mainnet view. Docker Compose keeps everything reproducible and easy to upgrade.

---

## 2. Repo Architecture

```text
.
├── docker-compose.yml   # Main Compose file
├── .env.example         # Copy to `.env` to set versions and ports
├── .gitignore           # Keeps bulky chain data out of Git
├── scripts/             # Helper tools
│   ├── gen-jwt-secret.sh
│   ├── prune-geth.sh
│   └── backup.sh
└── data/                # Empty folders mapped as Docker volumes
    ├── geth/
    └── lighthouse/
```

Anything you edit stays in Git. Chain databases under `data/` are ignored so the repo stays small.

---

## 3. Quick start

```bash
# 1 Clone and enter the folder
$ git clone https://github.com/<your‑handle>/ethereum-docker-node.git
$ cd ethereum-docker-node

# 2 Create your own .env file
$ cp .env.example .env   # then edit if you want different versions or ports

# 3 Make a shared JWT secret for EL ⇄ CL auth
$ ./scripts/gen-jwt-secret.sh

# 4 Pull images and fire it up
$ docker compose pull
$ docker compose up -d

# 5 Watch logs
$ docker compose logs -f geth lighthouse
```

Expect **≈ 100 GB** for Geth and **≈ 12 GB** for Lighthouse right after snap‑sync. Give yourself at least **300 GB** of fast SSD space and **8 GB** RAM (set in `%UserProfile%\\.wslconfig`).

---

## 4. docker‑compose.yml (main piece)

```yaml
version: "3.9"

x-logging: &default-logging
  driver: json-file
  options:
    max-size: "100m"
    max-file: "3"

services:
  geth:
    image: ethereum/client-go:${GETH_VERSION}
    restart: unless-stopped
    command: >
      geth --mainnet \
           --syncmode=snap \
           --http --http.addr=0.0.0.0 --http.vhosts="*" \
           --http.api="eth,net,web3" \
           --authrpc.addr=0.0.0.0 --authrpc.port=8551 \
           --authrpc.vhosts="*" --authrpc.jwtsecret=/jwt/jwt.hex \
           --datadir=/opt/geth \
           --metrics --metrics.addr=0.0.0.0 --metrics.port=6060
    volumes:
      - ./data/geth:/opt/geth
      - ./jwtsecret:/jwt:ro
    ports:
      - "8545:8545"   # JSON‑RPC
      - "8551:8551"   # Engine API
      - "30303:30303" # P2P
    logging: *default-logging

  lighthouse:
    image: sigp/lighthouse:${LIGHTHOUSE_VERSION}
    restart: unless-stopped
    depends_on:
      - geth
    command: >
      lighthouse bn \
        --network mainnet \
        --datadir=/opt/lighthouse \
        --execution-endpoints=http://geth:8551 \
        --execution-jwt=/jwt/jwt.hex \
        --checkpoint-sync-url="https://checkpoint.mainnet.ethereum.org" \
        --metrics \
        --validator-monitor-auto
    volumes:
      - ./data/lighthouse:/opt/lighthouse
      - ./jwtsecret:/jwt:ro
    ports:
      - "9000:9000"   # P2P
      - "5052:5052"   # REST API
      - "5054:5054"   # Metrics
    logging: *default-logging

networks:
  default:
    name: eth-node-net
    driver: bridge
```

Image versions come from `.env` so upgrades are one‑line edits.

---

## 5. .env.example

```dotenv
# Versions checked in April 2025
GETH_VERSION=v1.15.8
LIGHTHOUSE_VERSION=v5.3.0

# Change these if ports collide with other apps
GETH_RPC_PORT=8545
LIGHTHOUSE_REST_PORT=5052
```

---

## 6. Helper scripts

| Script | What it does |
|--------|--------------|
| `gen-jwt-secret.sh` | Creates a 32‑byte secret so Geth and Lighthouse can trust each other. Run once. |
| `prune-geth.sh` | Removes old state snapshots to save disk. Schedule it weekly if you like. |
| `backup.sh` | Stops the node, tars your `data/` folder, then restarts. Handy for cold backups. |

Make them executable with `chmod +x scripts/*.sh`.

---

## 7. Windows 10 Home setup

1. Turn on hardware virtualisation (VT‑x/AMD‑V) in BIOS.
2. Open PowerShell as admin:
   ```powershell
   wsl --install -d Ubuntu-22.04
   wsl --set-default-version 2
   ```
3. Install Docker Desktop ≥ 4.30 and enable WSL 2 integration for Ubuntu.
4. (Optional) Limit resources in `%UserProfile%\\.wslconfig`:
   ```ini
   [wsl2]
   memory=12GB
   processors=8
   swap=0
   ```
5. Reboot.

---

## 8. Useful commands

| Goal | Command |
|------|---------|
| Check Geth syncing | `docker compose exec geth geth attach --exec eth.syncing` |
| Check Lighthouse syncing | `curl -s localhost:5052/eth/v1/node/syncing | jq` |
| Follow logs | `docker compose logs -f --tail=100 geth lighthouse` |
| See disk use | `du -sh data/*` |
| Prune old state | `docker compose exec geth geth db state prune --datadir=/opt/geth --size=110GB` |

---

## 9. References

* **Geth v1.15.8** release notes – Ethereum Foundation
* **Lighthouse v5.3.0** release notes – Sigma Prime
* Microsoft Docs – Tuning WSL 2 performance

---

### License

MIT – do whatever you want, just no warranty.

