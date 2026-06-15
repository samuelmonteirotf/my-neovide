--------------------------------------------------------------------------------
-- Autocommands
--
-- Format-on-save is handled by LazyVim/conform.nvim (see plugins/devops.lua for
-- the per-filetype formatter list). This file only adds DevOps filetype
-- detection that Neovim does not ship out of the box.
--------------------------------------------------------------------------------

local ft = vim.filetype

-- ─────────────────────────────────────────────────────────────────────────────
-- DevOps filetype detection
--   * Ansible playbooks/roles → yaml.ansible (drives ansible-language-server)
--   * Compose / k8s / CI manifests stay plain yaml (yamlls + SchemaStore)
--   * HCL family: Packer / Terragrunt / generic .hcl
--   * Dockerfiles with suffixes (Dockerfile.prod, app.dockerfile)
-- ─────────────────────────────────────────────────────────────────────────────
ft.add({
  extension = {
    hcl = "hcl",
    tftpl = "terraform",
    nomad = "hcl",
    http = "http",
    rest = "http",
  },
  filename = {
    ["Tiltfile"] = "starlark",
    [".terraformrc"] = "hcl",
    ["terraform.rc"] = "hcl",
  },
  pattern = {
    [".*/playbooks/.*%.ya?ml"] = "yaml.ansible",
    [".*/roles/.*/tasks/.*%.ya?ml"] = "yaml.ansible",
    [".*/roles/.*/handlers/.*%.ya?ml"] = "yaml.ansible",
    [".*/%.github/workflows/.*%.ya?ml"] = "yaml",
    ["%.gitlab%-ci%.ya?ml"] = "yaml",
    ["[Dd]ockerfile.*"] = "dockerfile",
    [".*%.dockerfile"] = "dockerfile",
    [".*/templates/.*%.tpl"] = "helm",
    [".*/templates/.*%.ya?ml"] = "helm",
  },
})

-- ─────────────────────────────────────────────────────────────────────────────
-- Terminal buffers: no line numbers, start in insert (IDE-style terminal pane)
-- ─────────────────────────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("UserTerminal", { clear = true }),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.cmd("startinsert")
  end,
  desc = "Terminal: hide numbers, enter insert mode",
})
