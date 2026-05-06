--------------------------------------------------------------------------------
-- Editor options (overrides on top of LazyVim defaults)
--------------------------------------------------------------------------------

local opt = vim.opt

-- ── Indentation (2 spaces — TS/React/Lua house style) ────────────────────────
opt.shiftwidth  = 2
opt.tabstop     = 2
opt.expandtab   = true

-- ── Navigation ───────────────────────────────────────────────────────────────
opt.relativenumber = true   -- enables `10j` / `5k` motion counts
opt.scrolloff      = 8      -- keep cursor 8 lines away from screen edges
opt.sidescrolloff  = 8

-- ── Visual ───────────────────────────────────────────────────────────────────
opt.wrap        = false     -- code: no soft-wrap (overridden in markdown)
opt.colorcolumn = "80"      -- 80-column ruler

-- ── Performance ──────────────────────────────────────────────────────────────
opt.updatetime  = 50        -- faster CursorHold (LSP hover, gitsigns)
opt.timeoutlen  = 300       -- which-key popup delay
opt.ttimeoutlen = 0         -- ESC sequence: instant
opt.redrawtime  = 1500
opt.synmaxcol   = 300       -- skip syntax on absurdly long lines (logs/min.js)
opt.history     = 200

-- ── Bytecode cache (Neovim ≥ 0.9): faster startup ────────────────────────────
if vim.loader then vim.loader.enable() end

-- ── Disable unused language providers (saves ~50ms on startup) ───────────────
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider    = 0
vim.g.loaded_perl_provider    = 0
vim.g.loaded_node_provider    = 0
