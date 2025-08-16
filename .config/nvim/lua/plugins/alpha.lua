return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Set header
    dashboard.section.header.val = {
      "                                            ",
      "    ███╗   ██╗ ██████╗ ██████╗ ██████╗      ",
      "    ████╗  ██║██╔═████╗██╔══██╗╚════██╗     ",
      "    ██╔██╗ ██║██║██╔██║██║  ██║ █████╔╝     ",
      "    ██║╚██╗██║████╔╝██║██║  ██║ ╚═══██╗     ",
      "    ██║ ╚████║╚██████╔╝██████╔╝██████╔╝     ",
      "    ╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚═════╝      ",
      "                                            ",
    }

    -- Set menu with fixed icons
    dashboard.section.buttons.val = {
      dashboard.button("e", "  > New file", ":ene <BAR> startinsert <CR>"),
      dashboard.button("f", "  > Find file", ":Telescope find_files<CR>"),
      dashboard.button("r", "  > Recent files", ":Telescope oldfiles<CR>"),
      dashboard.button("g", "  > Find text", ":Telescope live_grep<CR>"),
      dashboard.button("c", "  > Config", ":e $MYVIMRC<CR>"),
      dashboard.button("q", "  > Quit", ":qa<CR>"),
    }

    -- Footer
    local function footer()
      local total_plugins = require("lazy").stats().count
      local datetime = os.date(" %d-%m-%Y   %H:%M:%S")
      return "   " .. total_plugins .. " plugins" .. datetime
    end

    dashboard.section.footer.val = footer()

    -- Layout
    dashboard.config.layout = {
      { type = "padding", val = 10 },
      dashboard.section.header,
      { type = "padding", val = 5 },
      dashboard.section.buttons,
      { type = "padding", val = 1 },
      dashboard.section.footer,
    }

    -- Disable folding on alpha buffer
    vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])

    alpha.setup(dashboard.config)
  end,
}
