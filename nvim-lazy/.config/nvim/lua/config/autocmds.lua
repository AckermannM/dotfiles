-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- disable progress on noice for cs files
-- as roslyn doesn't adhere to progres LSP spec
-- see https://github.com/dotnet/roslyn/issues/79939
vim.api.nvim_create_autocmd("FileType", {
  pattern = "cs",
  callback = function()
    vim.api.nvim_clear_autocmds({
      group = "noice_lsp_progress",
      event = "LspProgress",
      pattern = "*",
    })
  end,
})
