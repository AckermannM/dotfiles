return {
  "goolord/alpha-nvim",
  dependencies = { "BlakeJC94/alpha-nvim-fortune" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")
    local fortune = require("alpha.fortune")

    dashboard.section.header.val = {
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
      " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
      " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
      " ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
      " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
      " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
    }

    dashboard.section.header.opts.hl = "DiagnosticOk"

    dashboard.section.buttons.val = {
      dashboard.button("e", "  New file", ":ene <CR>"),
      dashboard.button("SPC pv", "󰙅  Browse files", ":Neotree current<CR>"),
      dashboard.button("SPC ff", "  Find file", ":Telescope find_files<CR>"),
      dashboard.button("SPC fg", "󱎸  Find text", ":Telescope live_grep<CR>"),
      dashboard.button("SPC fb", "  Buffers", ":Telescope buffers<CR>"),
      dashboard.button("SPC fh", "󰞋  Help", ":Telescope help_tags<CR>"),
      dashboard.button("q", "󰅚  Quit NVIM", ":qa<CR>"),
    }
    -- Set footer
    dashboard.section.footer.val = fortune()
    alpha.setup(dashboard.opts)
  end,
}
