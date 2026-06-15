std = "luajit"
max_line_length = false

read_globals = {
  "vim",
  "LazyVim",
  "Snacks",
}

ignore = {
  "212", -- unused argument (plugin opts callbacks: (_, opts))
  "122", -- setting read-only field of global (vim.g.*, vim.o.*)
}
