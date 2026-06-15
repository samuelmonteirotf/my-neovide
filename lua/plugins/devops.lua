--------------------------------------------------------------------------------
-- DevOps polish that the LazyVim lang extras don't cover on their own:
-- shell tooling (no bash extra exists), guaranteed linters/formatters, and a
-- yaml-language-server tweak so it stops fighting yamllint over key order.
--------------------------------------------------------------------------------

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = {},
        yamlls = {
          settings = { yaml = { keyOrdering = false } },
        },
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "bash-language-server",
        "shfmt",
        "shellcheck",
        "tflint",
        "yamllint",
        "hadolint",
      })
    end,
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        sh = { "shfmt" },
        bash = { "shfmt" },
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        sh = { "shellcheck" },
        bash = { "shellcheck" },
      },
    },
  },

  {
    "folke/which-key.nvim",
    opts = { spec = { { "<leader>h", group = "harpoon", icon = "󰛢" } } },
  },
}
