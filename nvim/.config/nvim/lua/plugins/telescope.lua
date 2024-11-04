return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        pickers = {
          find_files = {
            hidden = true,
          },
        },
      })
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", function()
        builtin.find_files({
          cwd = vim.fn.getcwd(),
        })
      end, { desc = "Telescope find files" })
      vim.keymap.set(
        "n",
        "<leader>fi",
        builtin.current_buffer_fuzzy_find,
        { desc = "Telescope find inside file" }
      )
      vim.keymap.set("n", "<leader>fv", builtin.git_files, { desc = "Telescope git files" })
      vim.keymap.set("n", "<leader>fg", function()
        builtin.live_grep({
          cwd = vim.fn.getcwd(),
        })
      end, { desc = "Telescope live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
    end,
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })
      require("telescope").load_extension("ui-select")
    end,
  },
  {
    "Slotos/telescope-lsp-handlers.nvim",
    config = function()
      require("telescope-lsp-handlers").setup()
    end,
  },
}
