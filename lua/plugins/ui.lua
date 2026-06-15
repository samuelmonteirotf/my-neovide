--------------------------------------------------------------------------------
-- UI: theme, breadcrumbs, statusline, dashboard. The "IDE chrome".
--------------------------------------------------------------------------------

-- Cached Kubernetes context, refreshed off the hot path. Empty when kubectl is
-- absent or no context is set, so the statusline component simply disappears.
local kube = { ctx = "" }

local function refresh_kube()
  if vim.fn.executable("kubectl") == 0 then
    return
  end
  vim.system({ "kubectl", "config", "current-context" }, { text = true }, function(res)
    vim.schedule(function()
      kube.ctx = (res.code == 0 and vim.trim(res.stdout or "")) or ""
    end)
  end)
end

vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained", "DirChanged" }, {
  group = vim.api.nvim_create_augroup("UserKubeContext", { clear = true }),
  callback = refresh_kube,
})

local function kube_context()
  return kube.ctx ~= "" and ("󱃾 " .. kube.ctx) or ""
end

return {
  ----------------------------------------------------------------------------
  -- Tokyo Night (Moon) — matches the Kitty terminal theme.
  ----------------------------------------------------------------------------
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = { style = "moon", transparent = true },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "tokyonight" } },

  ----------------------------------------------------------------------------
  -- dropbar — IDE-style breadcrumb winbar (file path + LSP symbols).
  ----------------------------------------------------------------------------
  {
    "Bekaboo/dropbar.nvim",
    event = "LazyFile",
    opts = {},
    keys = {
      {
        "<leader>;",
        function()
          require("dropbar.api").pick()
        end,
        desc = "Breadcrumbs: pick",
      },
    },
  },

  ----------------------------------------------------------------------------
  -- Lualine — add the live Kubernetes context on the right.
  ----------------------------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, 1, {
        kube_context,
        color = { fg = "#7aa2f7" },
      })
    end,
  },

  ----------------------------------------------------------------------------
  -- Snacks dashboard — DevOps banner + ops-oriented shortcuts.
  ----------------------------------------------------------------------------
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.dashboard = opts.dashboard or {}
      opts.dashboard.preset = opts.dashboard.preset or {}

      opts.dashboard.preset.header = table.concat({
        "",
        "  ██████╗ ███████╗██╗   ██╗ ██████╗ ██████╗ ███████╗",
        "  ██╔══██╗██╔════╝██║   ██║██╔═══██╗██╔══██╗██╔════╝",
        "  ██║  ██║█████╗  ██║   ██║██║   ██║██████╔╝███████╗",
        "  ██║  ██║██╔══╝  ╚██╗ ██╔╝██║   ██║██╔═══╝ ╚════██║",
        "  ██████╔╝███████╗ ╚████╔╝ ╚██████╔╝██║     ███████║",
        "  ╚═════╝ ╚══════╝  ╚═══╝   ╚═════╝ ╚═╝     ╚══════╝",
        "",
      }, "\n")

      opts.dashboard.preset.keys = {
        { icon = " ", key = "f", desc = "Find file", action = ":lua Snacks.dashboard.pick('files')" },
        { icon = " ", key = "g", desc = "Grep", action = ":lua Snacks.dashboard.pick('live_grep')" },
        { icon = " ", key = "r", desc = "Recent files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
        { icon = "󱃾 ", key = "k", desc = "k9s cluster", action = ":K9s" },
        { icon = " ", key = "t", desc = "Terminal", action = ":lua Snacks.terminal()" },
        { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
        { icon = "󰢫 ", key = "m", desc = "Mason", action = ":Mason" },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      }
    end,
  },
}
