return {
  {
    "mbbill/undotree",
    keys = {
      {
        "<leader>U",
        "<cmd>UndotreeToggle<cr>",
        desc = "Toggle undotree",
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts_extend = { "spec" },
    opts = {
      spec = {
        {
          { "<leader>U", icon = { icon = " ", color = "blue" }, desc = "Toggle undotree", mode = "n" },
        },
      },
    },
  },
}
