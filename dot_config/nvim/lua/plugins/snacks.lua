return {
  "snacks.nvim",
  opts = {
    scroll = {
      enabled = false,
    },
    picker = {
      -- Same deal for every picker (<leader>ff, <leader>/, <leader>sw, ...):
      -- dotfiles are searchable, gitignored build output is not.
      hidden = true,
      ignored = false,
      sources = {
        -- `files` is the one source that hard-codes `hidden = false` in the
        -- snacks defaults, and source defaults are merged *after* the global
        -- picker opts above -- so it needs the setting repeated here.
        files = {
          hidden = true,
          ignored = false,
        },
        explorer = {
          -- Show dotfiles by default (this repo is almost entirely `.config/`
          -- inside the stowable dirs), but keep gitignored files hidden so
          -- node_modules / bin / obj / generated stay out of the way.
          -- `include` wins over `hidden`, `ignored` *and* `exclude`, so the
          -- globs below stay visible even when git ignores them.
          hidden = true,
          ignored = false,
          include = {
            "**/.env",
            "**/.env.*",
            "**/appsettings.json",
            "**/appsettings.*.json",
            "**/launchSettings.json",
            "**/launchsettings.json",
          },
          exclude = {
            "**/.git",
          },
          win = {
            list = {
              keys = {
                -- snacks binds <c-f> to preview_scroll_down in every picker by
                -- default, which as a buffer-local mapping shadows the global
                -- <C-f> herdr-sessionizer keymap. Free it up in the file tree only.
                ["<c-f>"] = false,
              },
            },
          },
        },
      },
    },
    dashboard = {
      preset = {
        pick = function(cmd, opts)
          return LazyVim.pick(cmd, opts)()
        end,
        header = [[
███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗
████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║
██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║
██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║
██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║
╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝
]],
      },
    },
  },
}
