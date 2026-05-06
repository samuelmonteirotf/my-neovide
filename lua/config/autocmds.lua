--------------------------------------------------------------------------------
-- Autocommands
--------------------------------------------------------------------------------

-- ─────────────────────────────────────────────────────────────────────────────
-- Format-on-save via LSP (excludes prose-y filetypes which use conform.nvim)
-- ─────────────────────────────────────────────────────────────────────────────
local fmt_group = vim.api.nvim_create_augroup("UserFormatOnSave", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  group   = fmt_group,
  pattern = "*",
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    local skip = { gitcommit = true, markdown = true, log = true, text = true }
    if skip[ft] then return end
    vim.lsp.buf.format({ async = false, bufnr = args.buf, timeout_ms = 2000 })
  end,
  desc = "Format buffer with LSP on save (skips prose filetypes)",
})

-- ─────────────────────────────────────────────────────────────────────────────
-- Markdown / prose writing mode
--   * Soft-wrap with `linebreak` (no mid-word breaks)
--   * Spell-check in pt-BR + en simultaneously
--   * conceallevel=2 lets render-markdown.nvim hide ** and _ markers
--   * j/k navigate visual lines (so wrapped paragraphs feel natural)
-- ─────────────────────────────────────────────────────────────────────────────
local md_group = vim.api.nvim_create_augroup("UserMarkdownWriting", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group   = md_group,
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap          = true
    vim.opt_local.linebreak     = true
    vim.opt_local.breakindent   = true
    vim.opt_local.spell         = true
    vim.opt_local.spelllang     = "pt_br,en"   -- bilingual spell-check
    vim.opt_local.conceallevel  = 2
    vim.opt_local.concealcursor = ""           -- show raw markers on cursor line
    vim.opt_local.colorcolumn   = ""           -- no 80-col ruler in prose
    vim.opt_local.textwidth     = 0

    -- Visual-line motion (Markdown wraps soft, j should follow the wrap)
    vim.keymap.set("n", "j", "gj", { buffer = true })
    vim.keymap.set("n", "k", "gk", { buffer = true })
  end,
  desc = "Markdown/prose: wrap, bilingual spell, conceal, visual j/k",
})
