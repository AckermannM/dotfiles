-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

-- delete move lines with ALT
vim.keymap.del({ "n", "v", "i" }, "<A-j>")
vim.keymap.del({ "n", "v", "i" }, "<A-k>")

-- delete unused dap keymaps
vim.keymap.del({ "n" }, "<leader>dr")
vim.keymap.del({ "n" }, "<leader>dw")

-- Move lines up and down with Shift + J/K only in visual mode
map({ "v" }, "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map({ "v" }, "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

map({ "n" }, "<leader>dw", function()
  require("dapui").eval(nil, { enter = true })
end, { noremap = true, silent = true, desc = "Add word under cursor to Watches" })

map({ "n" }, "Q", function()
  require("dapui").eval()
end, {
  noremap = true,
  silent = true,
  desc = "Hover/eval a single value (opens a tiny window instead of expanding the full object) ",
})
