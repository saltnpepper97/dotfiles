return {
  "catgoose/nvim-colorizer.lua",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("colorizer").setup({
      filetypes = { "*" }, -- Specify filetypes here
      user_default_options = {
        -- Default options
        RGB = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        names = true, -- "Name" codes like Blue or red
        RRGGBBAA = true, -- #RRGGBBAA hex codes
        AARRGGBB = true, -- 0xAARRGGBB hex codes
        rgb_fn = true, -- CSS rgb() and rgba() functions
        hsl_fn = false, -- CSS hsl() and hsla() functions
        css = false, -- Enable all CSS features
        css_fn = false, -- Enable all CSS *functions*
        mode = "virtualtext", -- foreground | background | virtualtext
        tailwind = false,
        sass = { enable = false, parsers = { "css" } },
        virtualtext = "■",
        virtualtext_inline = "before",
        virtualtext_mode = "foreground",
        always_update = false,
      }
    })
  end,
}
