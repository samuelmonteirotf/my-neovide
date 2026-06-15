--------------------------------------------------------------------------------
-- Editor: treesitter, text objects, and editing primitives.
--------------------------------------------------------------------------------

return {
  ----------------------------------------------------------------------------
  -- Treesitter — make sure the DevOps grammar set is present, plus textobjects.
  -- (The LazyVim lang extras already pull most of these; listing is idempotent.)
  ----------------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "terraform",
        "hcl",
        "yaml",
        "json",
        "jsonc",
        "toml",
        "dockerfile",
        "go",
        "gomod",
        "gosum",
        "gowork",
        "python",
        "bash",
        "lua",
        "markdown",
        "markdown_inline",
        "regex",
        "git_config",
        "gitignore",
        "gitcommit",
        "diff",
        "ssh_config",
      })

      opts.textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = { query = "@function.outer", desc = "Around function" },
            ["if"] = { query = "@function.inner", desc = "Inside function" },
            ["ac"] = { query = "@class.outer", desc = "Around class/block" },
            ["ic"] = { query = "@class.inner", desc = "Inside class/block" },
            ["aa"] = { query = "@parameter.outer", desc = "Around argument" },
            ["ia"] = { query = "@parameter.inner", desc = "Inside argument" },
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
        },
      }
    end,
  },

  ----------------------------------------------------------------------------
  -- Treesitter Context — sticky header with the enclosing block (resource,
  -- function, job, task). Invaluable in long Terraform/YAML files.
  ----------------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "LazyFile",
    opts = { max_lines = 3, multiline_threshold = 1, trim_scope = "outer", mode = "cursor" },
    keys = {
      {
        "[x",
        function()
          require("treesitter-context").go_to_context()
        end,
        desc = "Jump to context",
      },
    },
  },

  ----------------------------------------------------------------------------
  -- vim-illuminate — highlight other occurrences of the symbol under cursor.
  ----------------------------------------------------------------------------
  {
    "RRethy/vim-illuminate",
    event = "LazyFile",
    config = function()
      require("illuminate").configure({
        providers = { "lsp", "treesitter", "regex" },
        delay = 100,
        filetypes_denylist = { "neo-tree", "snacks_dashboard", "oil", "Outline", "dbui" },
      })
    end,
  },

  ----------------------------------------------------------------------------
  -- Oil — edit the filesystem like a buffer. `-` opens the parent directory.
  ----------------------------------------------------------------------------
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = { { "-", "<cmd>Oil<CR>", desc = "Open Oil (parent dir)" } },
    opts = {
      default_file_explorer = false,
      view_options = { show_hidden = true },
      keymaps = { ["q"] = "actions.close" },
    },
  },

  ----------------------------------------------------------------------------
  -- mini.move — Alt+h/j/k/l moves lines/blocks.
  ----------------------------------------------------------------------------
  {
    "nvim-mini/mini.move",
    event = "VeryLazy",
    opts = {
      mappings = {
        left = "<M-h>",
        right = "<M-l>",
        down = "<M-j>",
        up = "<M-k>",
        line_left = "<M-h>",
        line_right = "<M-l>",
        line_down = "<M-j>",
        line_up = "<M-k>",
      },
    },
  },

  ----------------------------------------------------------------------------
  -- mini.surround — gsa/gsd/gsr to add/delete/replace surrounding pairs.
  ----------------------------------------------------------------------------
  {
    "nvim-mini/mini.surround",
    event = "VeryLazy",
    opts = {
      mappings = {
        add = "gsa",
        delete = "gsd",
        replace = "gsr",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        update_n_lines = "gsn",
      },
    },
  },

  ----------------------------------------------------------------------------
  -- Undotree — visualise the undo history as a side panel.
  ----------------------------------------------------------------------------
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = { { "<leader>U", "<cmd>UndotreeToggle<CR>", desc = "Toggle Undotree" } },
  },

  ----------------------------------------------------------------------------
  -- Spectre — project-wide search & replace with live preview.
  ----------------------------------------------------------------------------
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    keys = {
      {
        "<leader>sR",
        function()
          require("spectre").open()
        end,
        desc = "Spectre (project replace)",
      },
      {
        "<leader>sw",
        function()
          require("spectre").open_visual({ select_word = true })
        end,
        desc = "Spectre (word under cursor)",
      },
    },
  },
}
