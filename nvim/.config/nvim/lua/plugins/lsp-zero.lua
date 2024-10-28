return {
	"VonHeikemen/lsp-zero.nvim",
	branch = "v4.x",
	dependencies = {
		"neovim/nvim-lspconfig",
		"neovim/nvim-lspconfig",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/nvim-cmp",
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
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
			ensure_installed = { "lua_ls", "ts_ls" },
		})

		-- This is where you enable features that only work
		-- if there is a language server active in the file
		vim.api.nvim_create_autocmd("LspAttach", {
			desc = "LSP actions",
			callback = function(event)
				local opts = { buffer = event.buf, remap = false }

				vim.keymap.set("n", "K", function()
					vim.lsp.buf.hover()
				end, opts)
				vim.keymap.set("n", "gd", function()
					vim.lsp.buf.definition()
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
				--vim.keymap.set({ "n", "x" }, "<leader>f", function() vim.lsp.buf.format({async = true}) end, opts)
				vim.keymap.set("n", "<leader>ca", function()
					vim.lsp.buf.code_action()
				end, opts)
			end,
		})

		local lspconfig = require("lspconfig")
		lspconfig.lua_ls.setup({})
		lspconfig.ts_ls.setup({})

		local cmp = require("cmp")

		cmp.setup({
			sources = {
				{ name = "nvim_lsp" },
			},
			snippet = {
				expand = function(args)
					-- You need Neovim v0.10 to use vim.snippet
					vim.snippet.expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({}),
		})
	end,
}
