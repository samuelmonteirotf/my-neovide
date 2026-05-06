--------------------------------------------------------------------------------
-- Editor: text-editing primitives that help in BOTH code and prose.
-- Loaded in terminal AND Neovide modes.
--------------------------------------------------------------------------------

return {
  ----------------------------------------------------------------------------
  -- Treesitter textobjects — vaf/vac/vap to select function/class/argument.
  -- Useful in code; in Markdown the parser also exposes @scope (block quotes,
  -- code blocks), so the same motions work in prose.
  ----------------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    opts = function(_, opts)
      opts.textobjects = {
        select = {
          enable    = true,
          lookahead = true,
          keymaps = {
            ["af"] = { query = "@function.outer",  desc = "Around function" },
            ["if"] = { query = "@function.inner",  desc = "Inside function" },
            ["ac"] = { query = "@class.outer",     desc = "Around class"    },
            ["ic"] = { query = "@class.inner",     desc = "Inside class"    },
            ["aa"] = { query = "@parameter.outer", desc = "Around argument" },
            ["ia"] = { query = "@parameter.inner", desc = "Inside argument" },
          },
        },
        move = {
          enable    = true,
          set_jumps = true,
          goto_next_start     = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
        },
      }
    end,
  },

  ----------------------------------------------------------------------------
  -- Oil — edit the filesystem like a buffer. `-` opens parent directory.
  -- In docs mode this is the fastest way to jump between .md files.
  ----------------------------------------------------------------------------
  {
    "stevearc/oil.nvim",
    cmd  = "Oil",
    keys = { { "-", "<cmd>Oil<CR>", desc = "Open Oil (parent dir)" } },
    opts = {
      default_file_explorer = false,
      view_options          = { show_hidden = true },
      keymaps               = { ["q"] = "actions.close" },
    },
  },

  ----------------------------------------------------------------------------
  -- mini.move — Alt+h/j/k/l moves lines/blocks (works on prose too).
  ----------------------------------------------------------------------------
  {
    "nvim-mini/mini.move",
    event = "VeryLazy",
    opts  = {
      mappings = {
        left  = "<M-h>", right = "<M-l>", down  = "<M-j>", up    = "<M-k>",
        line_left = "<M-h>", line_right = "<M-l>",
        line_down = "<M-j>", line_up    = "<M-k>",
      },
    },
  },

  ----------------------------------------------------------------------------
  -- mini.surround — wrap text with **bold**, _italic_, `code`, [links].
  --   gsa{motion}{char}  →  add surround
  --   gsd{char}          →  delete surround
  --   gsr{old}{new}      →  replace surround
  ----------------------------------------------------------------------------
  {
    "nvim-mini/mini.surround",
    event = "VeryLazy",
    opts  = {
      mappings = {
        add = "gsa", delete = "gsd", replace = "gsr",
        find = "gsf", find_left = "gsF",
        highlight = "gsh", update_n_lines = "gsn",
      },
    },
  },

  ----------------------------------------------------------------------------
  -- Undotree — visualise the undo tree as a side panel.
  ----------------------------------------------------------------------------
  {
    "mbbill/undotree",
    cmd  = "UndotreeToggle",
    keys = { { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Toggle Undotree" } },
  },

  ----------------------------------------------------------------------------
  -- Spectre — project-wide search & replace with live preview.
  ----------------------------------------------------------------------------
  {
    "nvim-pack/nvim-spectre",
    cmd  = "Spectre",
    keys = {
      { "<leader>sR", function() require("spectre").open() end,                                desc = "Spectre (project replace)" },
      { "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end,   desc = "Spectre (word under cursor)" },
    },
  },
}
