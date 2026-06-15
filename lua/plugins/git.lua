--------------------------------------------------------------------------------
-- Git tool window. LazyVim already ships lazygit (<leader>gg) and gitsigns
-- (<leader>gh hunks); this adds Neogit (staging/commit UI) and Diffview
-- (side-by-side diff + merge-conflict resolver + file history).
--------------------------------------------------------------------------------

return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
    opts = { enhanced_diff_hl = true },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diffview (working tree)" },
      { "<leader>gD", "<cmd>DiffviewFileHistory %<CR>", desc = "Diffview (file history)" },
      { "<leader>gx", "<cmd>DiffviewClose<CR>", desc = "Diffview close" },
    },
  },
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    opts = { integrations = { diffview = true } },
    keys = { { "<leader>gn", "<cmd>Neogit<CR>", desc = "Neogit" } },
  },
}
