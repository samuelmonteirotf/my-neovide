--------------------------------------------------------------------------------
-- Integrated terminal + DevOps TUIs.
--
-- Uses LazyVim's built-in Snacks terminal (so there is no clash with the
-- default <c-/> toggle) to host the cluster/container cockpits. The generic
-- float terminal stays on <c-/>.
--------------------------------------------------------------------------------

local function run_tui(cmd)
  return function()
    if vim.fn.executable(cmd) == 0 then
      vim.notify(cmd .. " not found in PATH", vim.log.levels.WARN)
      return
    end
    require("snacks").terminal(cmd, { win = { style = "terminal" } })
  end
end

vim.api.nvim_create_user_command("K9s", run_tui("k9s"), { desc = "Open k9s" })
vim.api.nvim_create_user_command("LazyDocker", run_tui("lazydocker"), { desc = "Open lazydocker" })

return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>tk", run_tui("k9s"), desc = "k9s (cluster)" },
      { "<leader>tl", run_tui("lazydocker"), desc = "lazydocker (containers)" },
      {
        "<leader>tt",
        function()
          require("snacks").terminal()
        end,
        desc = "Terminal (float)",
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = { spec = { { "<leader>t", group = "terminal/ops", icon = " " } } },
  },
}
