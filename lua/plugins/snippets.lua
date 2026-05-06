--------------------------------------------------------------------------------
-- Markdown / Obsidian snippet pack.
--
-- Triggers (type the word, press <Tab>):
--   frontmatter  full YAML header with title/tags/created
--   daily        daily-note skeleton (date + sections)
--   meeting      meeting-note skeleton (attendees + agenda + actions)
--   note         quick note with frontmatter
--   task         "- [ ] " task line
--   link         [[wikilink]]
--   tag          #tag
--   ref          [text](url) Markdown link
--   img          ![alt](attachments/img.png)
--   now          inserts current timestamp YYYY-MM-DD HH:MM
--   table        4×3 table skeleton
--   note!        callout "> [!note]"
--   tip!         callout "> [!tip]"
--   warn!        callout "> [!warning]"
--   info!        callout "> [!info]"
--   quote        "> "  blockquote line
--   lua / py / ts / rs / bash / sh / json   fenced code blocks
--
-- Loaded in both modes (LuaSnip is already in LazyVim; adding snippets is free).
--------------------------------------------------------------------------------

return {
  {
    "L3MON4D3/LuaSnip",
    config = function(_, opts)
      require("luasnip").config.setup(opts)

      local ls = require("luasnip")
      local s  = ls.snippet
      local t  = ls.text_node
      local i  = ls.insert_node
      local f  = ls.function_node

      local function today()    return os.date("%Y-%m-%d")          end
      local function timestamp() return os.date("%Y-%m-%d %H:%M")    end

      ls.add_snippets("markdown", {
        ------------------------------------------------------------------------
        -- Frontmatter & note skeletons
        ------------------------------------------------------------------------
        s("frontmatter", {
          t({ "---", "title: " }),     i(1, "Title"),
          t({ "",   "tags: [" }),      i(2, "tag"),
          t({ "]",  "created: " }),    f(today),
          t({ "",   "---", "", "# " }), i(3, "Heading"),
          t({ "", "", "" }),           i(0),
        }),

        s("note", {
          t({ "---", "title: " }),  i(1, "Title"),
          t({ "",   "tags: [" }),   i(2, "note"),
          t({ "]",  "created: " }), f(today),
          t({ "", "---", "", "# " }), f(function(args) return args[1][1] end, { 1 }),
          t({ "", "", "" }),         i(0),
        }),

        s("daily", {
          t({ "---", "title: Daily " }), f(today),
          t({ "",   "tags: [daily]",
                    "created: " }),     f(today),
          t({ "",   "---", "",
                    "# " }),            f(today),
          t({ "", "",
                    "## Foco do dia",
                    "",
                    "- [ ] " }),        i(1, "main task"),
          t({ "", "",
                    "## Notas",
                    "",
                    "" }),              i(0),
          t({ "", "",
                    "## Reflexão",
                    "" }),
        }),

        s("meeting", {
          t({ "---", "title: Meeting " }), i(1, "topic"),
          t({ "",   "date: " }),           f(today),
          t({ "",   "tags: [meeting]",
                    "attendees: [" }),     i(2, "you, them"),
          t({ "]",  "---", "",
                    "# " }),               f(function(args) return "Meeting — " .. args[1][1] end, { 1 }),
          t({ "", "",
                    "## Agenda",
                    "",
                    "- " }),               i(3, "topic"),
          t({ "", "",
                    "## Notas",
                    "",
                    "" }),                 i(0),
          t({ "", "",
                    "## Action items",
                    "",
                    "- [ ] " }),
        }),

        ------------------------------------------------------------------------
        -- Inline elements
        ------------------------------------------------------------------------
        s("task", { t("- [ ] "),  i(0) }),
        s("link", { t("[["),      i(1, "note"), t("]]"), i(0) }),
        s("tag",  { t("#"),       i(1, "tag"),  t(" "),  i(0) }),
        s("ref",  { t("["),       i(1, "text"), t("]("), i(2, "url"), t(")"), i(0) }),
        s("img",  { t("!["),      i(1, "alt"),  t("](attachments/"), i(2, "image.png"), t(")"), i(0) }),
        s("now",  { f(timestamp) }),

        ------------------------------------------------------------------------
        -- Tables
        ------------------------------------------------------------------------
        s("table", {
          t({ "| " }), i(1, "Col 1"),
          t({ " | " }), i(2, "Col 2"),
          t({ " | " }), i(3, "Col 3"),
          t({ " |",
              "|---|---|---|",
              "| " }), i(4, "a"),
          t({ " | " }), i(5, "b"),
          t({ " | " }), i(6, "c"),
          t({ " |",
              "" }),    i(0),
        }),

        ------------------------------------------------------------------------
        -- Obsidian callouts
        ------------------------------------------------------------------------
        s("note!", { t({ "> [!note] " }), i(1, "Title"), t({ "", "> " }), i(0) }),
        s("tip!",  { t({ "> [!tip] "  }), i(1, "Title"), t({ "", "> " }), i(0) }),
        s("warn!", { t({ "> [!warning] " }), i(1, "Title"), t({ "", "> " }), i(0) }),
        s("info!", { t({ "> [!info] " }), i(1, "Title"), t({ "", "> " }), i(0) }),
        s("quote", { t("> "), i(0) }),

        ------------------------------------------------------------------------
        -- Fenced code blocks
        ------------------------------------------------------------------------
        s("lua",  { t({ "```lua",  "" }), i(0), t({ "", "```" }) }),
        s("py",   { t({ "```python", "" }), i(0), t({ "", "```" }) }),
        s("ts",   { t({ "```typescript", "" }), i(0), t({ "", "```" }) }),
        s("rs",   { t({ "```rust", "" }), i(0), t({ "", "```" }) }),
        s("bash", { t({ "```bash", "" }), i(0), t({ "", "```" }) }),
        s("sh",   { t({ "```sh",   "" }), i(0), t({ "", "```" }) }),
        s("json", { t({ "```json", "" }), i(0), t({ "", "```" }) }),
      })
    end,
  },
}
