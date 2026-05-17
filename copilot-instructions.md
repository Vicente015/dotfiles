## Dev Environment

Terminal commands run inside a Fedora Toolbox container (`dev`) on Fedora Silverblue.

- Shell: `/bin/bash` (not fish)
- Hostname: `toolbx`

### Tool sources

| Source | Tools |
|---|---|
| `~/.volta/bin` | `node`, `pnpm`, `deno` |
| `~/.bun/bin` | `bun` |
| `/run/host/home/linuxbrew/.linuxbrew/bin` | `starship`, `eza`, `bat`, `glow`, `kagi`, `delta`, `micro`, `brew` |
| `/usr/bin` | `git`, `rg`, `fd`, `fzf`, `jq`, `zoxide`, `gcc`, `make` |

### Kagi web search (in scripts use `ai_raw`, not `ai`)

```bash
ai_raw "query"       # plain markdown → stdout
aic_raw "follow-up"  # continue thread
ai "query"           # interactive only (renders via glow)
```

### Security: masked paths (empty/unreadable inside container)

`~/.ssh`, `~/.gnupg`, `~/secrets`, `~/.kagi.toml`, `~/.npmrc`
