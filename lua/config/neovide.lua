--------------------------------------------------------------------------------
-- Neovide GUI configuration (no-op when running as plain `nvim`)
--
-- Performance posture: every animation/effect that costs GPU without a clear
-- payoff is OFF. Render only what changed; idle drops to 5fps to save battery.
--------------------------------------------------------------------------------

if not vim.g.neovide then
  return
end

-- ── Font ─────────────────────────────────────────────────────────────────────
-- "NL" = no ligatures: less shaping work per frame.
-- "Mono" = strict monospace: predictable column widths.
vim.o.guifont = "JetBrainsMonoNL Nerd Font Mono:h14"
vim.o.linespace = 0

-- ── Refresh rate ─────────────────────────────────────────────────────────────
-- MacBook Air M2 13" panel is 60Hz (no ProMotion). Going higher wastes GPU.
vim.g.neovide_refresh_rate = 60
vim.g.neovide_refresh_rate_idle = 5
vim.g.neovide_no_idle = false

-- ── Window ───────────────────────────────────────────────────────────────────
vim.g.neovide_remember_window_size = true
vim.g.neovide_confirm_quit = false -- ⌘Q exits without prompt
vim.g.neovide_profiler = false
vim.g.neovide_theme = "auto"

-- ── Effects: all disabled for max throughput ─────────────────────────────────
-- Transparency/blur cost GPU per frame; opaque background = faster compositing.
vim.g.neovide_opacity = 1.0
vim.g.neovide_window_blurred = false
vim.g.neovide_floating_blur_amount_x = 0.0
vim.g.neovide_floating_blur_amount_y = 0.0
vim.g.neovide_floating_shadow = false
vim.g.neovide_show_border = false
vim.g.neovide_underline_stroke_scale = 1.0
vim.g.neovide_unlink_border_highlights = true

-- ── Cursor: instant response, no particles ───────────────────────────────────
vim.g.neovide_cursor_animation_length = 0.0
vim.g.neovide_cursor_trail_size = 0.0
vim.g.neovide_cursor_animate_in_insert_mode = false
vim.g.neovide_cursor_animate_command_line = false
vim.g.neovide_cursor_smooth_blink = false
vim.g.neovide_cursor_vfx_mode = ""
vim.g.neovide_cursor_antialiasing = true -- cheap, keep

-- ── Scroll / position: no interpolation ──────────────────────────────────────
vim.g.neovide_scroll_animation_length = 0.0
vim.g.neovide_scroll_animation_far_lines = 0
vim.g.neovide_position_animation_length = 0.0

vim.g.neovide_hide_mouse_when_typing = true

-- ── macOS modifier mapping ───────────────────────────────────────────────────
-- Left Option → Meta (so <M-…> mappings work).
-- Right Option stays "alt" so dead keys (acentos, ç) still work for typing.
vim.g.neovide_input_macos_option_key_is_meta = "only_left"
vim.g.neovide_input_use_logo = true

-- ── Zoom: ⌘= / ⌘- / ⌘0 ───────────────────────────────────────────────────────
vim.g.neovide_scale_factor = 1.0

local function change_scale(delta)
  vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + delta
end

vim.keymap.set("n", "<D-=>", function()
  change_scale(0.1)
end, { desc = "Neovide zoom in" })
vim.keymap.set("n", "<D-->", function()
  change_scale(-0.1)
end, { desc = "Neovide zoom out" })
vim.keymap.set("n", "<D-0>", function()
  vim.g.neovide_scale_factor = 1.0
end, { desc = "Neovide zoom reset" })

-- ── Standard macOS clipboard shortcuts ───────────────────────────────────────
vim.keymap.set({ "n", "v" }, "<D-c>", '"+y', { desc = "Copy" })
vim.keymap.set({ "n", "v" }, "<D-x>", '"+x', { desc = "Cut" })
vim.keymap.set({ "n", "v" }, "<D-v>", '"+p', { desc = "Paste" })
vim.keymap.set("i", "<D-v>", "<C-r>+", { desc = "Paste (insert)" })
vim.keymap.set("c", "<D-v>", "<C-r>+", { desc = "Paste (cmdline)" })
vim.keymap.set("n", "<D-a>", "ggVG", { desc = "Select all" })
vim.keymap.set("n", "<D-s>", "<cmd>w<CR>", { desc = "Save" })
vim.keymap.set("n", "<D-z>", "u", { desc = "Undo" })
vim.keymap.set("n", "<D-S-z>", "<C-r>", { desc = "Redo" })
