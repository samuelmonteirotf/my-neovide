--------------------------------------------------------------------------------
-- Overseer — the "Run/Build configurations" panel. Run terraform/kubectl/
-- docker/ansible/helm tasks and watch their output in a dedicated window.
--------------------------------------------------------------------------------

return {
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerQuickAction", "OverseerInfo" },
    keys = {
      { "<leader>or", "<cmd>OverseerRun<CR>", desc = "Run task" },
      { "<leader>ot", "<cmd>OverseerToggle<CR>", desc = "Task list" },
      { "<leader>oa", "<cmd>OverseerQuickAction<CR>", desc = "Task action" },
      { "<leader>oi", "<cmd>OverseerInfo<CR>", desc = "Overseer info" },
    },
    opts = { templates = { "builtin" } },
    config = function(_, opts)
      local overseer = require("overseer")
      overseer.setup(opts)

      local function register(name, cmd, args, filetypes)
        overseer.register_template({
          name = name,
          builder = function()
            return { cmd = { cmd }, args = args, components = { "default" } }
          end,
          condition = filetypes and { filetype = filetypes } or nil,
        })
      end

      register("terraform: init", "terraform", { "init" }, { "terraform", "hcl" })
      register("terraform: plan", "terraform", { "plan" }, { "terraform", "hcl" })
      register("terraform: apply", "terraform", { "apply", "-auto-approve" }, { "terraform", "hcl" })
      register("terraform: validate", "terraform", { "validate" }, { "terraform", "hcl" })
      register("ansible: lint playbook", "ansible-lint", {}, { "yaml.ansible" })

      overseer.register_template({
        name = "kubectl: apply current file",
        builder = function()
          return { cmd = { "kubectl" }, args = { "apply", "-f", vim.fn.expand("%:p") } }
        end,
        condition = { filetype = { "yaml", "helm" } },
      })

      overseer.register_template({
        name = "kubectl: delete current file",
        builder = function()
          return { cmd = { "kubectl" }, args = { "delete", "-f", vim.fn.expand("%:p") } }
        end,
        condition = { filetype = { "yaml", "helm" } },
      })

      overseer.register_template({
        name = "ansible-playbook: run current file",
        builder = function()
          return { cmd = { "ansible-playbook" }, args = { vim.fn.expand("%:p") } }
        end,
        condition = { filetype = { "yaml.ansible" } },
      })

      overseer.register_template({
        name = "helm: upgrade --install (chart dir)",
        builder = function()
          local dir = vim.fn.expand("%:p:h")
          return {
            cmd = { "helm" },
            args = { "upgrade", "--install", vim.fn.fnamemodify(dir, ":t"), dir },
          }
        end,
        condition = { filetype = { "helm", "yaml" } },
      })
    end,
  },
  {
    "folke/which-key.nvim",
    opts = { spec = { { "<leader>o", group = "overseer/tasks", icon = "" } } },
  },
}
