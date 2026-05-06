--------------------------------------------------------------------------------
-- Docs-only plugin stack. Loaded ONLY when launched via Neovide.
-- Goal: turn Neovide into a focused Markdown writing environment for
-- bilingual notes (pt-BR + en).
--------------------------------------------------------------------------------

local only_neovide = function() return vim.g.neovide ~= nil end

return {
  ----------------------------------------------------------------------------
  -- 1. render-markdown.nvim — in-buffer rendering (Obsidian-like look).
  --    Coloured headings, ☐/☑ checkboxes, fenced-code backgrounds, aligned
  --    tables, quote bars. Works alongside spell-check and the LSPs below.
  ----------------------------------------------------------------------------
  {
    "MeanderingProgrammer/render-markdown.nvim",
    cond         = only_neovide,
    ft           = { "markdown", "Avante" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      heading  = { sign = false, width = "block", left_pad = 1 },
      code     = { sign = false, width = "block", left_pad = 2, right_pad = 2 },
      checkbox = {
        unchecked = { icon = "󰄱 " },
        checked   = { icon = "󰱒 " },
      },
      bullet     = { icons = { "●", "○", "◆", "◇" } },
      pipe_table = { preset = "round" },
    },
  },

  ----------------------------------------------------------------------------
  -- 2. markdown-preview.nvim — live browser preview, scroll-synced.
  ----------------------------------------------------------------------------
  {
    "iamcco/markdown-preview.nvim",
    cond  = only_neovide,
    cmd   = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft    = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
    keys  = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", desc = "Markdown preview (browser)" },
    },
    config = function()
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_theme      = "dark"
    end,
  },

  ----------------------------------------------------------------------------
  -- 3. zen-mode — fullscreen, distraction-free writing.
  ----------------------------------------------------------------------------
  {
    "folke/zen-mode.nvim",
    cond = only_neovide,
    cmd  = "ZenMode",
    keys = { { "<leader>z", "<cmd>ZenMode<CR>", desc = "Zen mode (focus)" } },
    opts = {
      window = {
        backdrop = 0.95,
        width    = 90,
        options  = {
          number = false, relativenumber = false,
          cursorline = false, signcolumn = "no",
        },
      },
      plugins = {
        options  = { laststatus = 0 },
        twilight = { enabled = true },
      },
    },
  },

  ----------------------------------------------------------------------------
  -- 4. twilight — dim everything except the current paragraph.
  ----------------------------------------------------------------------------
  {
    "folke/twilight.nvim",
    cond = only_neovide,
    cmd  = { "Twilight", "TwilightEnable" },
    keys = { { "<leader>tw", "<cmd>Twilight<CR>", desc = "Twilight (dim)" } },
    opts = { dimming = { alpha = 0.25 }, context = 10 },
  },

  ----------------------------------------------------------------------------
  -- 5. autolist — Markdown lists continue themselves on Enter / o / O.
  --    Renumbers `1. 2. 3.` when an item is deleted.
  ----------------------------------------------------------------------------
  {
    "gaoDean/autolist.nvim",
    cond = only_neovide,
    ft   = { "markdown", "text", "gitcommit" },
    config = function()
      require("autolist").setup()
      vim.keymap.set("i", "<CR>",      "<CR><cmd>AutolistNewBullet<CR>")
      vim.keymap.set("n", "o",         "o<cmd>AutolistNewBullet<CR>")
      vim.keymap.set("n", "O",         "O<cmd>AutolistNewBulletBefore<CR>")
      vim.keymap.set("n", "<C-r>",     "<cmd>AutolistRecalculate<CR>",     { desc = "Renumber list"   })
      vim.keymap.set("n", "<leader>x", "<cmd>AutolistToggleCheckbox<CR>",  { desc = "Toggle checkbox" })
    end,
  },

  ----------------------------------------------------------------------------
  -- 6. obsidian.nvim — vault of linked notes, daily notes, frontmatter.
  --    Default vault: ~/Documents/Notes. Works without the Obsidian app.
  ----------------------------------------------------------------------------
  {
    "epwalsh/obsidian.nvim",
    cond         = only_neovide,
    version      = "*",
    ft           = "markdown",
    cmd          = {
      "ObsidianNew", "ObsidianOpen", "ObsidianSearch", "ObsidianToday",
      "ObsidianFollowLink", "ObsidianBacklinks", "ObsidianTags",
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>on", "<cmd>ObsidianNew<CR>",        desc = "Obsidian: new note"    },
      { "<leader>oo", "<cmd>ObsidianSearch<CR>",     desc = "Obsidian: search"      },
      { "<leader>od", "<cmd>ObsidianToday<CR>",      desc = "Obsidian: daily note"  },
      { "<leader>of", "<cmd>ObsidianFollowLink<CR>", desc = "Obsidian: follow link" },
      { "<leader>ob", "<cmd>ObsidianBacklinks<CR>",  desc = "Obsidian: backlinks"   },
      { "<leader>ot", "<cmd>ObsidianTags<CR>",       desc = "Obsidian: tags"        },
    },
    opts = {
      workspaces  = { { name = "notes", path = "~/Documents/Notes" } },
      daily_notes = { folder = "daily", date_format = "%Y-%m-%d" },
      completion  = { nvim_cmp = false, blink = true, min_chars = 2 },
      ui          = { enable = false }, -- render-markdown.nvim handles visuals
      attachments = { img_folder = "attachments" },
    },
  },

  ----------------------------------------------------------------------------
  -- 7. vim-table-mode — tables that auto-align as you type.
  --    Toggle with <leader>tm; type `|col1|col2|` and the cells line up.
  ----------------------------------------------------------------------------
  {
    "dhruvasagar/vim-table-mode",
    cond = only_neovide,
    cmd  = { "TableModeToggle", "Tableize" },
    keys = { { "<leader>tm", "<cmd>TableModeToggle<CR>", desc = "Table mode toggle" } },
    init = function()
      vim.g.table_mode_corner     = "|"   -- pure Markdown corner style
      vim.g.table_mode_align_char = ":"
    end,
  },

  ----------------------------------------------------------------------------
  -- 8. LSPs for prose — configured through LazyVim's lspconfig spec.
  --
  --    marksman → completion for [[wikilinks]], [refs], #headings, plus
  --               broken-link diagnostics and hover previews.
  --    ltex     → grammar/style checking (LanguageTool) bilingual pt-BR + en.
  --               Default language is pt-BR; switch per-buffer with
  --               :LtexLang en-US (mapped to <leader>cl below).
  ----------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    cond = only_neovide,
    opts = {
      servers = {
        marksman = {
          filetypes = { "markdown", "markdown.mdx" },
        },
        ltex = {
          filetypes = { "markdown", "text", "gitcommit" },
          settings  = {
            ltex = {
              language       = "pt-BR",          -- default; toggle with :LtexLang
              additionalRules = { motherTongue = "pt-BR" },
              disabledRules  = {
                ["pt-BR"] = { "WHITESPACE_RULE" },
                ["en-US"] = { "WHITESPACE_RULE" },
              },
            },
          },
        },
      },
    },
  },

  ----------------------------------------------------------------------------
  -- 9. conform.nvim — format Markdown with prettier on save (consistent
  --    line breaks, list markers, fences).
  ----------------------------------------------------------------------------
  {
    "stevearc/conform.nvim",
    cond = only_neovide,
    opts = {
      formatters_by_ft = {
        markdown         = { "prettier" },
        ["markdown.mdx"] = { "prettier" },
      },
    },
  },

  ----------------------------------------------------------------------------
  -- 10. mason.nvim — make sure the docs toolchain is installed locally.
  ----------------------------------------------------------------------------
  {
    "mason-org/mason.nvim",
    cond = only_neovide,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "marksman", "ltex-ls", "prettier", "markdownlint-cli2",
      })
    end,
  },

  ----------------------------------------------------------------------------
  -- 11. LtexLang command — switch grammar engine between pt-BR and en-US
  --     without restarting the LSP. Bound to <leader>cl<lang>.
  ----------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig", -- same spec, second entry: only adds the command
    cond = only_neovide,
    keys = {
      { "<leader>cp", "<cmd>LtexLang pt-BR<CR>", desc = "LTeX: switch to pt-BR" },
      { "<leader>ce", "<cmd>LtexLang en-US<CR>", desc = "LTeX: switch to en-US" },
    },
    config = function()
      vim.api.nvim_create_user_command("LtexLang", function(args)
        local lang = args.args
        for _, client in ipairs(vim.lsp.get_clients({ name = "ltex" })) do
          client.config.settings.ltex.language = lang
          client.notify("workspace/didChangeConfiguration",
                        { settings = client.config.settings })
        end
        vim.notify("LTeX language: " .. lang, vim.log.levels.INFO)
      end, {
        nargs    = 1,
        complete = function() return { "pt-BR", "en-US", "en-GB" } end,
        desc     = "Switch LTeX checking language",
      })
    end,
  },
}
