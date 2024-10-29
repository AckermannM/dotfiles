return {
  "goolord/alpha-nvim",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.buttons.val = {
      dashboard.button("e", "  New file", ":ene <CR>"),
      dashboard.button("SPC pv", "󰙅  Netrw", ":Ex<CR>"),
      dashboard.button("SPC ff", "  Find file", ":Telescope find_files<CR>"),
      dashboard.button("SPC fg", "󱎸  Find text", ":Telescope live_grep<CR>"),
      dashboard.button("SPC fb", "  Buffers", ":Telescope buffers<CR>"),
      dashboard.button("SPC fh", "󰞋  Help", ":Telescope help_tags<CR>"),
    }

    alpha.setup(dashboard.opts)
  end,
}
