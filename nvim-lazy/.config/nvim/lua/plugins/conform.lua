return {
  "stevearc/conform.nvim",
  optional = true,
  opts = {
    formatters_by_ft = {
      cs = { "csharpier" },
      zsh = { "shfmt" },
    },
    -- formatters = {
    --   csharpier = function()
    --     local useDotnet = not vim.fn.executable("csharpier")
    --     local command = useDotnet and "dotnet-csharpier" or "csharpier"
    --     local versionOut = vim.fn.system(command .. " --version")
    --
    --     -- NOTE: system command returns the command as the first line, so we get the last line
    --     local version_result = versionOut[#versionOut]
    --     local majorVersion = tonumber((versionOut or ""):match("^(%d+)")) or 0
    --     local isNew = majorVersion >= 1
    --
    --     local args = isNew and { "format", "$FILENAME" } or { "--write-stdout" }
    --
    --     return {
    --       command = command,
    --       args = args,
    --       stdin = not isNew,
    --       require_cwd = false,
    --     }
    --   end,
    -- },
  },
}
