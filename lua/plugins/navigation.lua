--------------------------------------------------------------------------------
-- Navigation: jump between files, buffers, and the wider repository.
-- Loaded in both terminal and Neovide modes.
--------------------------------------------------------------------------------

return {
  ----------------------------------------------------------------------------
  -- Harpoon — pin a handful of files for instant jumping (no fuzzy needed).
  -- <leader>a adds, <C-e> opens the menu, <C-h/t/n/s> jumps to slots 1-4.
  ----------------------------------------------------------------------------
  {
    "theprimeagen/harpoon",
    branch       = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      local map = vim.keymap.set
      map("n", "<leader>a", function() harpoon:list():add() end,                          { desc = "Harpoon: add file"  })
      map("n", "<C-e>",     function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,  { desc = "Harpoon: menu"      })
      map("n", "<C-h>",     function() harpoon:list():select(1) end,                      { desc = "Harpoon: slot 1"    })
      map("n", "<C-t>",     function() harpoon:list():select(2) end,                      { desc = "Harpoon: slot 2"    })
      map("n", "<C-n>",     function() harpoon:list():select(3) end,                      { desc = "Harpoon: slot 3"    })
      map("n", "<C-s>",     function() harpoon:list():select(4) end,                      { desc = "Harpoon: slot 4"    })
    end,
  },

  ----------------------------------------------------------------------------
  -- Flash — jump anywhere on the visible screen by typing a label.
  -- `s` = jump anywhere, `S` = jump by treesitter node.
  ----------------------------------------------------------------------------
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts  = {},
    keys  = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump()       end, desc = "Flash jump"       },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
    },
  },

  ----------------------------------------------------------------------------
  -- Telescope FZF native — replaces Lua matcher with the C fzf engine.
  ----------------------------------------------------------------------------
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build  = "make",
    config = function() require("telescope").load_extension("fzf") end,
  },

  ----------------------------------------------------------------------------
  -- LazyGit — fully-featured Git TUI, opened with <leader>gg.
  ----------------------------------------------------------------------------
  {
    "kdheepak/lazygit.nvim",
    cmd          = { "LazyGit", "LazyGitConfig" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys         = { { "<leader>gg", "<cmd>LazyGit<CR>", desc = "Open LazyGit" } },
  },
}
