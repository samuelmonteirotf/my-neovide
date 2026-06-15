--------------------------------------------------------------------------------
-- Global keymaps (work in both terminal and Neovide modes)
-- Mode-specific keymaps live next to their plugin spec.
--------------------------------------------------------------------------------

local map = vim.keymap.set

-- ── Window navigation (splits) ───────────────────────────────────────────────
map("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower split" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper split" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

-- ── Buffer management ────────────────────────────────────────────────────────
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close current buffer" })
map("n", "<leader>,", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>.", "<cmd>bnext<CR>", { desc = "Next buffer" })
