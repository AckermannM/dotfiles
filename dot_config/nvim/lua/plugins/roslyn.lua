return {
  "seblyng/roslyn.nvim",
  ---@module 'roslyn.config'
  ---@type RoslynNvimConfig
  ft = { "cs", "razor" },
  opts = {
    filewatching = "roslyn",
    broad_search = true,
    lock_target = true,
  },
  lazy = false,
  config = function(_, opts)
    local mason_path = vim.fn.stdpath("data") .. "/mason"
    local roslyn_path = mason_path .. "/packages/roslyn/libexec/Microsoft.CodeAnalysis.LanguageServer.dll"
    local dotnet10 = vim.fn.expand("~/.asdf/installs/dotnet-core/10.0.102/dotnet")

    vim.lsp.config("roslyn", {
      cmd = {
        dotnet10,
        roslyn_path,
        "--stdio",
        "--logLevel=Information",
        "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
      },
      settings = {
        ["csharp|background_analysis"] = {
          dotnet_analyzer_diagnostics_scope = "fullSolution",
          dotnet_compiler_diagnostics_scope = "fullSolution",
        },
        ["csharp|symbol_search"] = {
          dotnet_search_reference_assemblies = true,
        },
        ["csharp|inlay_hints"] = {
          csharp_enable_inlay_hints_for_implicit_object_creation = true,
          csharp_enable_inlay_hints_for_implicit_variable_types = true,

          csharp_enable_inlay_hints_for_lambda_parameter_types = true,
          csharp_enable_inlay_hints_for_types = true,
          dotnet_enable_inlay_hints_for_indexer_parameters = true,
          dotnet_enable_inlay_hints_for_literal_parameters = true,
          dotnet_enable_inlay_hints_for_object_creation_parameters = true,
          dotnet_enable_inlay_hints_for_other_parameters = true,
          dotnet_enable_inlay_hints_for_parameters = true,
          dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
          dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
          dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
        },
        ["csharp|code_lens"] = {
          dotnet_enable_references_code_lens = true,
        },
      },
    })
    vim.lsp.enable("roslyn")
  end,
  init = function()
    vim.filetype.add({
      extension = {
        cshtml = "razor",
        razor = "razor",
      },
    })
  end,
}
