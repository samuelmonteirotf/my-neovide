--------------------------------------------------------------------------------
-- Neovide-only GUI overrides.
-- Disables IDE-flavoured noise and adds writing-friendly widgets.
--------------------------------------------------------------------------------

if not vim.g.neovide then return {} end

--------------------------------------------------------------------------------
-- Lualine helpers — word count + estimated reading time (Markdown only).
--------------------------------------------------------------------------------

local PROSE_FT = { markdown = true, text = true }

local function word_count()
  if not PROSE_FT[vim.bo.filetype] then return "" end

  local mode = vim.fn.mode()
  if mode:match("[vV\22]") then
    local stats = vim.fn.wordcount()
    if stats.visual_words then
      return ("󰈭 %d words"):format(stats.visual_words)
    end
  end
  return ("󰈭 %d words"):format(vim.fn.wordcount().words)
end

-- Average reading speed: 200 words/minute.
local function read_time()
  if not PROSE_FT[vim.bo.filetype] then return "" end
  local words   = vim.fn.wordcount().words
  local minutes = math.max(1, math.ceil(words / 200))
  return ("󰔛 %d min"):format(minutes)
end

--------------------------------------------------------------------------------

return {
  ----------------------------------------------------------------------------
  -- Bufferline OFF — writing one document at a time, tabs are noise.
  ----------------------------------------------------------------------------
  { "akinsho/bufferline.nvim", enabled = false },

  ----------------------------------------------------------------------------
  -- Indent guides OFF — every list bullet would otherwise grow a vertical
  -- ruler, which clutters Markdown.
  ----------------------------------------------------------------------------
  { "nvim-mini/mini.indentscope", enabled = false },

  ----------------------------------------------------------------------------
  -- Lualine — append word-count and reading-time on the right.
  ----------------------------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_y, 1, { word_count })
      table.insert(opts.sections.lualine_y, 2, { read_time  })
    end,
  },

  ----------------------------------------------------------------------------
  -- Snacks dashboard — branded "NOTES" header + writing-oriented shortcuts.
  ----------------------------------------------------------------------------
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.dashboard         = opts.dashboard         or {}
      opts.dashboard.preset  = opts.dashboard.preset  or {}

      opts.dashboard.preset.header = table.concat({
        "",
        "  ██╗███╗   ██╗██╗  ██╗██╗    ██╗███████╗██╗     ██╗",
        "  ██║████╗  ██║██║ ██╔╝██║    ██║██╔════╝██║     ██║",
        "  ██║██╔██╗ ██║█████╔╝ ██║ █╗ ██║█████╗  ██║     ██║",
        "  ██║██║╚██╗██║██╔═██╗ ██║███╗██║██╔══╝  ██║     ██║",
        "  ██║██║ ╚████║██║  ██╗╚███╔███╔╝███████╗███████╗███████╗",
        "  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚══╝╚══╝ ╚══════╝╚══════╝╚══════╝",
        "",
      }, "\n")

      opts.dashboard.preset.keys = {
        { icon = " ", key = "n", desc = "New note",       action = ":ObsidianNew"   },
        { icon = " ", key = "d", desc = "Daily note",     action = ":ObsidianToday" },
        { icon = " ", key = "f", desc = "Search note",    action = ":ObsidianSearch" },
        { icon = " ", key = "r", desc = "Recent files",   action = ":lua Snacks.dashboard.pick('oldfiles')"  },
        { icon = " ", key = "g", desc = "Grep in vault",  action = ":lua Snacks.dashboard.pick('live_grep')" },
        { icon = " ", key = "z", desc = "Zen mode",       action = ":ZenMode"       },
        { icon = " ", key = "q", desc = "Quit",           action = ":qa"            },
      }
    end,
  },
}
