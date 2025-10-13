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
  dependencies = {
    {
      "tris203/rzls.nvim",
      config = true,
    },
  },
  lazy = false,
  config = function(_, opts)
    -- initialize the plugin
    -- require("roslyn").setup(opts)

    -- Use one of the methods in the Integration section to compose the command.
    local mason_registry = require("mason-registry")

    local rzls_path = vim.fn.expand("$MASON/packages/rzls/libexec")
    local cmd = {
      "roslyn",
      "--stdio",
      "--logLevel=Information",
      "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
      "--razorSourceGenerator=" .. vim.fs.joinpath(rzls_path, "Microsoft.CodeAnalysis.Razor.Compiler.dll"),
      "--razorDesignTimePath=" .. vim.fs.joinpath(rzls_path, "Targets", "Microsoft.NET.Sdk.Razor.DesignTime.targets"),
      "--extension",
      vim.fs.joinpath(rzls_path, "RazorExtension", "Microsoft.VisualStudioCode.RazorExtension.dll"),
    }

    vim.lsp.config("roslyn", {
      cmd = cmd,
      handlers = require("rzls.roslyn_handlers"),
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
