# my-neovide

A dual-mode Neovim configuration on top of LazyVim.

- Run as `nvim` in a terminal: full IDE — TypeScript, React, Rust, LSP, autocomplete, format-on-save.
- Launch with Neovide: turns into a focused Markdown writing studio — bilingual spell + grammar (pt-BR / en), in-buffer rendering, Obsidian-style vault, PDF/DOCX export.

The split is driven by `vim.g.neovide` evaluated at plugin load, so each side stays uncluttered.

---

## Layout

```
lua/
├── config/
│   ├── lazy.lua          bootstrap + diagnostics policy
│   ├── options.lua       editor options
│   ├── keymaps.lua       global keymaps
│   ├── autocmds.lua      format-on-save + Markdown writing mode
│   ├── neovide.lua       GUI tuning (font, refresh, cursor)
│   └── export.lua        :Mdpdf / :Mddocx commands (Neovide only)
└── plugins/
    ├── ui.lua            theme + lualine
    ├── editor.lua        textobjects, oil, mini.move/surround, undotree, spectre
    ├── navigation.lua    harpoon, flash, telescope-fzf, lazygit
    ├── snippets.lua      Markdown / Obsidian snippet pack
    ├── dev.lua           ts-context, illuminate, ts-autotag           (terminal only)
    ├── docs.lua          render-markdown, preview, zen, twilight,
    │                     obsidian, table-mode, marksman, ltex          (Neovide only)
    └── gui.lua           bufferline/indentscope off, word-count, dashboard (Neovide only)
```

---

## Requirements

- Neovim ≥ 0.10
- Nerd Font in your terminal
- `ripgrep`, `fd`, `lazygit`
- `pandoc` and `typst` (for PDF/DOCX export)
- `gcc` / build-essential (Treesitter, FZF native)

Optional but recommended for docs mode:

- `Neovide` ≥ 0.13 (`brew install --cask neovide`)

---

## Install

### Arch-based Linux (Arch, Manjaro, EndeavourOS, Garuda, CachyOS, Artix)

A single script handles every dependency, the clone, the first plugin sync, the Mason language servers and the shell aliases. It is idempotent — re-running is safe.

Inspect it first, then execute:

```bash
curl -fsSL https://raw.githubusercontent.com/samuelmonteirotf/my-neovide/main/scripts/install-arch.sh | less
curl -fsSL https://raw.githubusercontent.com/samuelmonteirotf/my-neovide/main/scripts/install-arch.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/samuelmonteirotf/my-neovide.git /tmp/my-neovide
bash /tmp/my-neovide/scripts/install-arch.sh
```

When it finishes:

```bash
source ~/.zshrc   # or ~/.bashrc
nv                # opens Neovide on your notes vault
```

### Manual install (any OS)

```bash
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
git clone https://github.com/samuelmonteirotf/my-neovide.git ~/.config/nvim
nvim   # plugins install on first launch
```

The Neovide-only stack only downloads when you launch via Neovide. Mason auto-installs `marksman`, `ltex-ls`, `prettier`, and `markdownlint-cli2` on the first Markdown buffer.

---

## Keymaps

Leader is `<Space>`.

### Common (both modes)

| Keys | Action |
|---|---|
| `<C-h/j/k/l>` | Move between splits |
| `<leader>,` / `<leader>.` | Previous / next buffer |
| `<leader>bd` | Close current buffer |
| `-` | Open Oil in parent directory |
| `<leader>u` | Toggle Undotree |
| `<leader>sR` | Project-wide replace (Spectre) |
| `<leader>a` / `<C-e>` | Harpoon: mark file / open menu |
| `<C-h/t/n/s>` | Harpoon slots 1–4 |
| `s` / `S` | Flash jump / Flash treesitter |
| `<leader>gg` | LazyGit |
| `gsa{motion}{char}` | Surround add (`gsa iw *` → `*word*`) |
| `<M-h/j/k/l>` | Move line/block |

### Docs mode (Neovide)

| Keys | Action |
|---|---|
| `<leader>mp` | Markdown preview in browser |
| `<leader>z` | Zen mode |
| `<leader>tw` | Twilight (dim everything except current paragraph) |
| `<leader>tm` | Table mode (auto-align as you type) |
| `<leader>x` | Toggle checkbox |
| `<C-r>` | Renumber list |
| `<leader>ep` | Export current buffer to PDF (typst engine) |
| `<leader>ed` | Export current buffer to DOCX |
| `<leader>eo` | Open last exported file in default app |
| `<leader>cp` / `<leader>ce` | LTeX language: pt-BR / en-US |
| `<leader>on/od/oo/of/ob/ot` | Obsidian: new / daily / search / follow / backlinks / tags |

---

## Snippets

Type a trigger in any Markdown buffer and press `<Tab>`:

`frontmatter` `note` `daily` `meeting` `task` `link` `tag` `ref` `img` `now`
`table` `note!` `tip!` `warn!` `info!` `quote`
`lua` `py` `ts` `rs` `bash` `sh` `json`

23 snippets total — see `lua/plugins/snippets.lua` for the full list.

---

## Bilingual writing (pt-BR + en)

- Spell-check: `spelllang = "pt_br,en"` — both dictionaries active simultaneously.
- Grammar: `ltex-ls` (LanguageTool) — defaults to pt-BR; switch with `:LtexLang en-US`.
- Diagnostics are turned **on** in Neovide mode and **off** in terminal mode, so grammar warnings only appear while writing prose.

---

## Performance posture

- `vim.loader` enabled (Lua bytecode cache).
- Python / Ruby / Perl / Node providers disabled (saves ~50 ms startup).
- Neovide refresh capped at 60 Hz (MacBook Air panel) with idle drop to 5 fps.
- All Neovide animations off — instant cursor, instant scroll.
- `synmaxcol = 300` skips syntax on minified / log lines.

---

## License

MIT
