--------------------------------------------------------------------------------
-- Dev-only plugins. Loaded ONLY when running plain `nvim` (terminal),
-- skipped when launched through Neovide (which is doc-focused).
--
-- vim.g.neovide is set by Neovide before Lazy evaluates `cond`, so the gate
-- is reliable.
--------------------------------------------------------------------------------

local only_terminal = function() return vim.g.neovide == nil end

return {
  ----------------------------------------------------------------------------
  -- Treesitter Context — sticky header showing the enclosing function/class.
  -- Saves scroll-back time in long files; pointless in Markdown.
  ----------------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter-context",
    cond  = only_terminal,
    event = "VeryLazy",
    opts  = {
      max_lines           = 3,
      multiline_threshold = 1,
      trim_scope          = "outer",
      mode                = "cursor",
    },
    keys = {
      { "[x", function() require("treesitter-context").go_to_context() end, desc = "Jump to context" },
    },
  },

  ----------------------------------------------------------------------------
  -- vim-illuminate — highlight every occurrence of the word under the cursor.
  -- Helpful in code; visual noise in prose.
  ----------------------------------------------------------------------------
  {
    "RRethy/vim-illuminate",
    cond  = only_terminal,
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("illuminate").configure({
        providers          = { "lsp", "treesitter", "regex" },
        delay              = 100,
        filetypes_denylist = {
          "dirvish", "fugitive", "neo-tree", "snacks_dashboard", "oil", "markdown",
        },
      })
    end,
  },

  ----------------------------------------------------------------------------
  -- nvim-ts-autotag — auto-close & rename JSX/HTML tags. No use in Markdown.
  ----------------------------------------------------------------------------
  {
    "windwp/nvim-ts-autotag",
    cond  = only_terminal,
    event = { "BufReadPost", "BufNewFile" },
    opts  = {},
  },
}
