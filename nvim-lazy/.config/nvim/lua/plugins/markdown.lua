-- LazyVim's `lang.markdown` extra runs markdownlint-cli2 over every markdown
-- buffer, and its defaults are noisy: MD013 (line length > 80) and MD010
-- (hard tabs, including inside fenced code blocks) fire constantly.
--
-- nvim-lint feeds the buffer in over stdin, and in that mode markdownlint-cli2
-- only picks up a config from the exact cwd -- it does not walk parent
-- directories. So a config file alone would rarely be found; it has to be
-- passed explicitly. `--config` sets the *base* configuration, which a
-- project-local .markdownlint-cli2.jsonc / .markdownlint.json still overrides.
local config = vim.fn.stdpath("config") .. "/markdownlint.jsonc"

return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        -- "-" is markdownlint-cli2's glob for stdin and must stay last.
        ["markdownlint-cli2"] = { args = { "--config", config, "-" } },
      },
      -- To turn markdown linting off entirely instead of just quieting it,
      -- add:  linters_by_ft = { markdown = {} },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters = {
        -- The `--fix` pass on save should honour the same rule set.
        ["markdownlint-cli2"] = { prepend_args = { "--config", config } },
      },
    },
  },
}
