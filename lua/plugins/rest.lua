--------------------------------------------------------------------------------
-- kulala — REST/HTTP client for .http files (probe APIs, webhooks, health
-- endpoints straight from the editor). Filetype detection lives in autocmds.lua.
--------------------------------------------------------------------------------

return {
  {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    opts = {},
    keys = {
      {
        "<leader>Rs",
        function()
          require("kulala").run()
        end,
        desc = "REST: send request",
      },
      {
        "<leader>Ra",
        function()
          require("kulala").run_all()
        end,
        desc = "REST: send all",
      },
      {
        "<leader>Rn",
        function()
          require("kulala").jump_next()
        end,
        desc = "REST: next request",
      },
      {
        "<leader>Rp",
        function()
          require("kulala").jump_prev()
        end,
        desc = "REST: previous request",
      },
      {
        "<leader>Rc",
        function()
          require("kulala").copy()
        end,
        desc = "REST: copy as curl",
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = { spec = { { "<leader>R", group = "REST client", icon = "" } } },
  },
}
