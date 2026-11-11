<div align="center">

# Delnegend Homebrew Tap

**Homebrew formulas for command-line tools and apps: tap once, install and update like anything else.**

[![License](https://img.shields.io/github/license/Delnegend/homebrew-tap?style=flat-square)](LICENSE)

</div>

---

## Quick Start

```bash
# 1. Tap once
brew tap Delnegend/tap

# 2. Install what you need
brew install mikrotik-mcp segotep-digital artefact-cli

# 3. Stay current
brew upgrade
```

## Highlights

- **One install line per tool**: no release pages, no asset names, no `chmod +x` dance.
- **Automatic updates**: a scheduled workflow checks supported upstream releases hourly; commit-pinned formulas are updated manually.
- **Shared formula machinery**: the three Brave Origin channels declare only their channel and inherit the install, livecheck, and desktop entry from one body.
- **A tap that documents itself**: every formula states its `desc` and `homepage`, so `brew info` answers before the README has to.

## Formulas

| Formula | What it installs |
|---|---|
| `artefact-cli` | JPEG artefact removal ([repo](https://github.com/Delnegend/artefact)), built from source |
| `brave-origin` | Brave browser, every feature on, from the upstream Linux release zip ([upstream](https://github.com/brave/brave-browser)) |
| `brave-origin-beta` | Same browser, beta channel |
| `brave-origin-nightly` | Same browser, nightly channel |
| `dpi-proxy` | HTTP proxy that helps applications reach services blocked by network traffic inspection ([repo](https://github.com/Delnegend/dpi-proxy)), Linux x86-64 |
| `libjxl` | JPEG XL encoder and decoder (`cjxl` and `djxl`) ([upstream](https://github.com/libjxl/libjxl)) |
| `mikrotik-mcp` | MCP server for MikroTik routers ([repo](https://github.com/Delnegend/mikrotik-mcp-server)) |
| `rsrpc` | Discord Rich Presence server ([repo](https://github.com/Delnegend/rsRPC)), fork of [SpikeHD/rsRPC](https://github.com/SpikeHD/rsRPC) |
| `rsrpc-bridge` | Proton/Wine IPC bridge for the above ([repo](https://github.com/Delnegend/rsRPC)); a Steam launch option, not a command |
| `segotep-digital` | Segotep cooler driver and service ([repo](https://github.com/Delnegend/segotep-digital)) |
| `zero-g` | OpenAI-compatible proxy for Google Antigravity subscriptions ([repo](https://github.com/Delnegend/zero-g)) |

## License

[MIT](LICENSE)
