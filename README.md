# my-neovide

A Neovim distribution optimized for DevOps engineers, built on LazyVim and tuned for Neovide. It provides an IDE-class experience featuring LSP, debugging, run configurations, Git integration, database client, REST client, breadcrumbs, and terminal. The distribution is tailored for DevOps technologies: Terraform, OpenTofu, Kubernetes, Helm, ArgoCD, Ansible, Docker, Go, Python, Bash, and CI/CD pipelines.

---

## Features

| Category | Tools |
| --- | --- |
| Languages / LSP | Terraform/HCL, YAML (with Kubernetes and Helm schemas), Ansible, Docker, Go, Python, Bash, JSON, TOML, SQL, Lua, Markdown |
| Linting / Formatting | tflint, yamllint, ansible-lint, hadolint, shellcheck, shfmt, gofumpt, ruff, prettier, stylua |
| Debugging (DAP) | Go (delve) and Python (debugpy) using `<F5>`, `<F10>`, `<F11>` step keys |
| Run Configurations | Overseer tasks: `terraform plan/apply`, `kubectl apply`, `ansible-playbook`, `helm upgrade` |
| Git Integration | lazygit via `<leader>gg`, gitsigns hunks, Neogit, Diffview (diff, merge, and history) |
| Cluster / Containers | k9s and lazydocker in a floating terminal, with live kube-context in the statusline |
| Database Client | vim-dadbod UI via the LazyVim SQL extra |
| REST Client | kulala to execute `.http` requests from the editor |
| Navigation | Telescope, Harpoon, Flash, dropbar breadcrumbs, Oil, Spectre |

---

## Structure

```
lua/
├── config/
│   ├── lazy.lua          bootstrap and diagnostics
│   ├── options.lua       editor options
│   ├── keymaps.lua       global keymaps
│   ├── autocmds.lua      DevOps filetype detection and terminal tweaks
│   └── neovide.lua       GUI tuning (font, refresh, cursor, clipboard)
└── plugins/
    ├── ui.lua            theme, dropbar breadcrumbs, dashboard, kube-context
    ├── editor.lua        treesitter, textobjects, context, oil, mini, spectre
    ├── navigation.lua    harpoon, flash, telescope-fzf
    ├── git.lua           neogit and diffview
    ├── terminal.lua      k9s, lazydocker, and floating terminal (Snacks)
    ├── tasks.lua         overseer run-configs (terraform/kubectl/ansible/helm)
    ├── dap.lua           IDE F-keys on top of the dap.core extra
    ├── rest.lua          kulala HTTP client
    ├── snippets.lua      DevOps snippet pack
    └── devops.lua        shell tooling, extra linters, and yamlls tweaks
```

Language configurations use LazyVim extras (defined in `lazyvim.json`). Each language includes LSP, treesitter parser, linter, and formatter integrations.

---

## Requirements

* Neovim 0.10 or higher (tested on 0.12)
* A Nerd Font
* `ripgrep`, `fd`, `git`, and a C compiler (`gcc` or `make` for Treesitter and fzf-native)
* Node.js and Python (required by Mason for language server installations)
* Optional CLI utilities: `kubectl`, `helm`, `k9s`, `lazydocker`, `lazygit`, `docker`, `terraform` or `tofu`, and `ansible`

Language servers, linters, and formatters are installed automatically by Mason on first launch. No manual installation of these components is required.

---

## Installation

### Automated Script (Arch Linux, Manjaro, EndeavourOS, CachyOS, Artix)

```bash
# Review the installation script
curl -fsSL https://raw.githubusercontent.com/samuelmonteirotf/my-neovide/main/scripts/install-arch.sh | less

# Execute the installation script
curl -fsSL https://raw.githubusercontent.com/samuelmonteirotf/my-neovide/main/scripts/install-arch.sh | bash
```

The script installs system dependencies, creates a backup of any existing Neovim configuration, clones the repository to `~/.config/nvim`, syncs plugins, and configures `nv` and `nvp` aliases.

### Manual Installation (All Operating Systems)

```bash
# Back up existing configuration
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null

# Clone the repository
git clone https://github.com/samuelmonteirotf/my-neovide.git ~/.config/nvim

# Launch Neovim to trigger automatic plugin and tool installation
nvim
```

---

## Keymaps

The leader key is configured to `<Space>`. LazyVim default keymaps are active. The table below outlines the custom keymaps added or modified in this distribution.

| Keymap | Action |
| --- | --- |
| `<C-h/j/k/l>` | Move between splits |
| `<leader>,` / `<leader>.` | Previous / next buffer |
| `-` | Open Oil (parent directory navigation) |
| `<leader>;` | Open dropbar breadcrumbs picker |
| `s` / `S` | Flash jump / Treesitter flash jump |
| `<leader>ha` / `<leader>hh` | Harpoon: add file / toggle menu |
| `<leader>h1…h4` | Harpoon: jump to files 1 to 4 |
| `<M-h/j/k/l>` | Move line or block |
| `<leader>sR` / `<leader>sw` | Spectre: project replace / search word under cursor |
| `<leader>U` | Toggle Undotree |
| **Git** | |
| `<leader>gg` | Open lazygit |
| `<leader>gn` | Open Neogit |
| `<leader>gd` / `<leader>gD` | Diffview: open working tree diff / view file history |
| **Debugging** | |
| `<F5>` / `<F10>` / `<F11>` / `<S-F11>` | DAP: continue / step over / step into / step out |
| `<leader>d…` | Access full DAP menu |
| **Tasks (Overseer)** | |
| `<leader>or` / `<leader>ot` | Run task / toggle task list |
| **Terminal / Operations** | |
| `<leader>tk` / `<leader>tl` | Launch k9s / lazydocker |
| `<leader>tt` / `<c-/>` | Toggle floating terminal |
| **REST Client** | |
| `<leader>Rs` / `<leader>Ra` | Send request / send all requests in `.http` file |

---

## Snippets

To trigger a snippet, enter the prefix and press `<Tab>`:

* **Dockerfile**: `dockerfile`
* **Kubernetes (YAML)**: `deploy`, `svc`, `ing`, `cm`, `ns`
* **CI/CD (YAML)**: `ghaction`
* **Terraform**: `res`, `data`, `var`, `out`, `mod`
* **Ansible**: `task`, `play`

---

## Development

To format and lint the codebase:

```bash
# Check formatting
stylua --check .

# Run static analysis
luacheck init.lua lua/
```

CI workflows (`.github/workflows/ci.yml`) execute these checks on every push or pull request to the `main` branch.

---

## License

MIT
