--------------------------------------------------------------------------------
-- UI: theme + statusline. Loaded in both terminal and Neovide modes.
--------------------------------------------------------------------------------

return {
  ----------------------------------------------------------------------------
  -- Tokyo Night (Moon) — matches the Kitty terminal theme.
  ----------------------------------------------------------------------------
  {
    "folke/tokyonight.nvim",
    lazy     = false,
    priority = 1000,
    opts     = { style = "moon", transparent = true },
  },

  -- Tell LazyVim to use it
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "tokyonight" },
  },

  ----------------------------------------------------------------------------
  -- Lualine — minimal "M2" badge on the right.
  -- Note: word-count widget for Markdown lives in plugins/gui.lua so the
  -- terminal status-line stays code-focused.
  ----------------------------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts  = function(_, opts)
      table.insert(opts.sections.lualine_x, {
        function() return " M2" end,
        padding = { left = 1, right = 1 },
        color   = { fg = "#7aa2f7" },
      })
    end,
  },
}
