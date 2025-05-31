-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- delete move lines with ALT
vim.keymap.del({ "n", "v", "i" }, "<A-j>")
vim.keymap.del({ "n", "v", "i" }, "<A-k>")

-- Move lines up and down with Shift + J/K only in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
