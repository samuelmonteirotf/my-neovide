--------------------------------------------------------------------------------
-- Navigation: jump between files, buffers, and the wider repository.
--------------------------------------------------------------------------------

return {
  ----------------------------------------------------------------------------
  -- Harpoon — pin a handful of files for instant jumping.
  -- Namespaced under <leader>h so it never collides with <C-h/j/k/l> splits.
  ----------------------------------------------------------------------------
  {
    "theprimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = function()
      local harpoon = require("harpoon")
      local function jump(i)
        return function()
          harpoon:list():select(i)
        end
      end
      return {
        {
          "<leader>ha",
          function()
            harpoon:list():add()
          end,
          desc = "Harpoon: add file",
        },
        {
          "<leader>hh",
          function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
          end,
          desc = "Harpoon: menu",
        },
        { "<leader>h1", jump(1), desc = "Harpoon: file 1" },
        { "<leader>h2", jump(2), desc = "Harpoon: file 2" },
        { "<leader>h3", jump(3), desc = "Harpoon: file 3" },
        { "<leader>h4", jump(4), desc = "Harpoon: file 4" },
      }
    end,
    config = function()
      require("harpoon"):setup()
    end,
  },

  ----------------------------------------------------------------------------
  -- Flash — jump anywhere on screen by typing a label.
  ----------------------------------------------------------------------------
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash jump",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash treesitter",
      },
    },
  },

  ----------------------------------------------------------------------------
  -- Telescope FZF native — C matcher for the picker.
  ----------------------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    optional = true,
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        enabled = vim.fn.executable("make") == 1,
        config = function()
          LazyVim.on_load("telescope.nvim", function()
            require("telescope").load_extension("fzf")
          end)
        end,
      },
    },
  },
}
