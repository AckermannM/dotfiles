return {
  "mason-org/mason.nvim",
  opts = {
    registries = {
      "github:mason-org/mason-registry",
      "github:Crashdummyy/mason-registry",
    },
    ensure_installed = {
      -- dotnet tools
      "csharpier",
      "roslyn",
      "netcoredbg",

      -- typescript/javascript tools
      "eslint-lsp",
      "eslint_d",
      "js-debug-adapter",
      "json-lsp",

      -- css tools
      "stylelint-lsp",
      "stylelint",

      -- bash
      "shellcheck",
      "shfmt",
    },
  },
}
