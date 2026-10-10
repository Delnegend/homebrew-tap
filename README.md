<div align="center">

# Delnegend Homebrew Tap

**Homebrew formulas for command-line tools and apps — tap once, install and update like anything else.**

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

- **One install line per tool** — no release pages, no asset names, no `chmod +x` dance.
- **Updated by a bot, not by hand** — a scheduled workflow watches every upstream release and commits the version bump straight to `main` hourly.
- **Shared formula machinery** — the three Brave Origin channels declare only their channel and inherit the install, livecheck, and desktop entry from one body.
- **A tap that documents itself** — every formula states its `desc` and `homepage`, so `brew info` answers before the README has to.

## Formulas

| Formula | What it installs |
|---|---|
| `artefact-cli` | JPEG artefact removal ([repo](https://github.com/Delnegend/artefact)) — built from source |
| `brave-origin` | Brave browser, every feature on, from the upstream Linux release zip ([upstream](https://github.com/brave/brave-browser)) |
| `brave-origin-beta` | Same browser, beta channel |
| `brave-origin-nightly` | Same browser, nightly channel |
| `forgejo-mcp` | MCP server for Forgejo ([repo](https://git.b4mad.industries/agentic-forges/forgejo-mcp)) |
| `mikrotik-mcp` | MCP server for MikroTik routers ([repo](https://github.com/Delnegend/mikrotik-mcp-server)) |
| `rsrpc` | Alternative Discord RPC server ([repo](https://github.com/SpikeHD/rsRPC)) |
| `segotep-digital` | Segotep cooler driver and service ([repo](https://github.com/Delnegend/segotep-digital)) |
| `tsuzuri` | Block-based notebook for the terminal ([upstream](https://github.com/jaisuriya-11/tsuzuri)) |

## License

[MIT](LICENSE)
