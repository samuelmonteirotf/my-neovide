--------------------------------------------------------------------------------
-- Debugging — the dap.core extra (+ lang.go / lang.python) provides the adapters
-- and the <leader>d… keymaps. This only adds the familiar IDE F-keys.
--------------------------------------------------------------------------------

return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    keys = {
      {
        "<F5>",
        function()
          require("dap").continue()
        end,
        desc = "Debug: continue",
      },
      {
        "<F10>",
        function()
          require("dap").step_over()
        end,
        desc = "Debug: step over",
      },
      {
        "<F11>",
        function()
          require("dap").step_into()
        end,
        desc = "Debug: step into",
      },
      {
        "<S-F11>",
        function()
          require("dap").step_out()
        end,
        desc = "Debug: step out",
      },
    },
  },
}
