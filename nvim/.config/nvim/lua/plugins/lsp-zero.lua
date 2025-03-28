-- Disable "No information available" notification on hover
-- plus define border for hover window
vim.lsp.handlers["textDocument/hover"] = function(_, result, ctx, config)
  config = config
      or {
        border = {
          { "╭", "Comment" },
          { "─", "Comment" },
          { "╮", "Comment" },
          { "│", "Comment" },
          { "╯", "Comment" },
          { "─", "Comment" },
          { "╰", "Comment" },
          { "│", "Comment" },
        },
      }
  config.focus_id = ctx.method
  if not (result and result.contents) then
    return
  end
  local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
  markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)
  if vim.tbl_isempty(markdown_lines) then
    return
  end
  return vim.lsp.util.open_floating_preview(markdown_lines, "markdown", config)
end

return {
  "VonHeikemen/lsp-zero.nvim",
  branch = "v4.x",
  dependencies = {
    "neovim/nvim-lspconfig",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/nvim-cmp",
    "onsails/lspkind.nvim",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "jay-babu/mason-null-ls.nvim",
    "pmizio/typescript-tools.nvim",
  },
  config = function()
    -- Add cmp_nvim_lsp capabilities settings to lspconfig
    -- This should be executed before you configure any language server
    local lspconfig_defaults = require("lspconfig").util.default_config
    lspconfig_defaults.capabilities = vim.tbl_deep_extend(
      "force",
      lspconfig_defaults.capabilities,
      require("cmp_nvim_lsp").default_capabilities()
    )

    require("mason").setup({})
    require("mason-lspconfig").setup({
      -- Replace the language servers listed here
      -- with the ones you want to install
      ensure_installed = {
        "lua_ls",
        "ts_ls",
        "omnisharp",
      },
    })
    require("mason-null-ls").setup({
      ensure_installed = {
        "eslint_d",
        "prettierd",
        "stylua",
        "csharpier",
      },
    })

    -- This is where you enable features that only work
    -- if there is a language server active in the file
    vim.api.nvim_create_autocmd("LspAttach", {
      desc = "LSP actions",
      callback = function(event)
        local opts = { buffer = event.buf, remap = false }
        local filetype = vim.api.nvim_buf_get_option(event.buf, "filetype")

        if filetype == "typescript" or filetype == "typescriptreact" then
          vim.keymap.set("n", "<leader>gd", [[:TSToolsGoToSourceDefinition<CR>]])
        end

        vim.keymap.set("n", "<leader>e", function()
          vim.diagnostic.open_float()
        end, opts)
        vim.keymap.set("n", "gd", function()
          vim.lsp.buf.definition()
        end, opts)
        vim.keymap.set("n", "K", function()
          vim.lsp.buf.hover()
        end, opts)
        vim.keymap.set("n", "<leader>gD", function()
          vim.lsp.buf.declaration()
        end, opts)
        vim.keymap.set("n", "<leader>gi", function()
          vim.lsp.buf.implementation()
        end, opts)
        vim.keymap.set("n", "<leader>go", function()
          vim.lsp.buf.type_definition()
        end, opts)
        vim.keymap.set("n", "<leader>gr", function()
          vim.lsp.buf.references()
        end, opts)
        vim.keymap.set("n", "<leader>gs", function()
          vim.lsp.buf.signature_help()
        end, opts)
        vim.keymap.set("n", "<leader>rn", function()
          vim.lsp.buf.rename()
        end, opts)
        vim.keymap.set("n", "<leader>ca", function()
          vim.lsp.buf.code_action()
        end, opts)
      end,
    })

    local lspconfig = require("lspconfig")
    lspconfig.lua_ls.setup({})
    require("typescript-tools").setup({
      on_attach = function(client, bufnr)
        -- Disable tsserver's formatting capability
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false

        -- Additional on_attach configuration if needed
      end,
    })
    lspconfig.omnisharp.setup({
      cmd = { "dotnet", "/home/ackermann/.local/share/nvim/mason/packages/omnisharp/libexec/OmniSharp.dll" },
      settings = {
        FormattingOptions = {
          -- Enables support for reading code style, naming convention and analyzer
          -- settings from .editorconfig.
          EnableEditorConfigSupport = true,
          -- Specifies whether 'using' directives should be grouped and sorted during
          -- document formatting.
          OrganizeImports = true,
        },
      },
    })

    require("luasnip.loaders.from_vscode").lazy_load()

    local cmp = require("cmp")
    local lspkind = require("lspkind")
    cmp.setup({
      completion = {
        completeopt = "menu,menuone,noinsert",
      },
      window = {
        completion = {
          border = {
            { "󱐋", "WarningMsg" },
            { "─", "Comment" },
            { "╮", "Comment" },
            { "│", "Comment" },
            { "╯", "Comment" },
            { "─", "Comment" },
            { "╰", "Comment" },
            { "│", "Comment" },
          },
          scrollbar = false,
          winblend = 0,
        },
        documentation = {
          border = {
            { "󰙎", "DiagnosticHint" },
            { "─", "Comment" },
            { "╮", "Comment" },
            { "│", "Comment" },
            { "╯", "Comment" },
            { "─", "Comment" },
            { "╰", "Comment" },
            { "│", "Comment" },
          },
          scrollbar = false,
          winblend = 0,
        },
      },
      formatting = {
        format = lspkind.cmp_format({
          mode = "symbol_text",
          menu = {
            nvim_lsp = " 󰘦 ",
            luasnip = "  ",
            path = "  ",
          },
        }),
      },
      sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "path" },
      },
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            local entry = cmp.get_selected_entry()
            if not entry then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Replace })
            else
              cmp.confirm()
            end
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
      }),
    })
    -- insert `(` after select function or method item
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  end,
}
