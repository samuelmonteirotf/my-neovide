--------------------------------------------------------------------------------
-- Markdown export (PDF / DOCX) via pandoc.
--   PDF engine: typst (modern, no LaTeX dependency, ~40MB).
--   DOCX:       pandoc native writer.
--
-- Pandoc auto-detects YAML frontmatter (`title:`, `author:`, `date:`) and
-- injects it into the output document.
--
-- Loaded only in Neovide (docs mode).
--------------------------------------------------------------------------------

if not vim.g.neovide then return end

local function exporter(extension, extra_args)
  return function()
    if vim.bo.filetype ~= "markdown" then
      vim.notify("Not a markdown buffer", vim.log.levels.WARN)
      return
    end

    local input = vim.api.nvim_buf_get_name(0)
    if input == "" then
      vim.notify("Save the file first", vim.log.levels.WARN)
      return
    end

    local output = vim.fn.fnamemodify(input, ":r") .. "." .. extension
    local cmd = vim.list_extend(
      { "pandoc", input, "-o", output, "--standalone" },
      extra_args or {}
    )

    vim.notify(("Exporting → %s"):format(vim.fn.fnamemodify(output, ":t")),
               vim.log.levels.INFO)

    vim.system(cmd, { text = true }, function(result)
      vim.schedule(function()
        if result.code == 0 then
          vim.notify(("✓ %s"):format(output), vim.log.levels.INFO)
        else
          vim.notify(("Pandoc failed:\n%s"):format(result.stderr or "unknown"),
                     vim.log.levels.ERROR)
        end
      end)
    end)
  end
end

local export_pdf  = exporter("pdf",  { "--pdf-engine=typst" })
local export_docx = exporter("docx", {})

vim.api.nvim_create_user_command("Mdpdf",  export_pdf,  { desc = "Export buffer to PDF (pandoc + typst)" })
vim.api.nvim_create_user_command("Mddocx", export_docx, { desc = "Export buffer to DOCX (pandoc)"        })

-- ── Keymaps active only in Markdown buffers ─────────────────────────────────
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    local map = function(lhs, fn, desc)
      vim.keymap.set("n", lhs, fn, { buffer = args.buf, desc = desc })
    end
    map("<leader>ep", export_pdf,  "Export → PDF (typst)")
    map("<leader>ed", export_docx, "Export → DOCX")
    map("<leader>eo", function()                             -- open exported file in macOS
      local base = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":r")
      for _, ext in ipairs({ "pdf", "docx" }) do
        local path = base .. "." .. ext
        if vim.fn.filereadable(path) == 1 then
          vim.system({ "open", path })
          return
        end
      end
      vim.notify("No exported PDF/DOCX found yet", vim.log.levels.WARN)
    end, "Open last exported file")
  end,
})
