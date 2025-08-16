return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons", -- for icons
  },
  config = function()
    local has_lualine, lualine = pcall(require, "lualine")
    if not has_lualine then
      return
    end

    local theme = "auto"
    local has_neopywal, neopywal_lualine = pcall(require, "neopywal.theme.plugins.lualine")
    if has_neopywal then
      neopywal_lualine.setup({
          mode_colors = {
              normal = "color4",
              visual = "color5",
              insert = "color2",
              command = "color1",
              replace = "color7",
              terminal = "color3",
          },
      })
      theme = "neopywal"
    end

    lualine.setup({
      options = {
        theme = theme, -- use neopywal if available
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
        icons_enabled = true,
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = {
          { "filename", path = 1 },
        },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      extensions = { "quickfix", "nvim-tree", "lazy" },
    })
  end,
}
