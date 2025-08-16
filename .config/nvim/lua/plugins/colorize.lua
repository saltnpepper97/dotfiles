return {
  "catgoose/nvim-colorizer.lua",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("colorizer").setup({"*" }, 
    {
      -- Default options
      RGB = true, -- #RGB hex codes
      RRGGBB = true, -- #RRGGBB hex codes
      names = true, -- "Name" codes like Blue or red
      RRGGBBAA = true, -- #RRGGBBAA hex codes
      AARRGGBB = false, -- 0xAARRGGBB hex codes
      rgb_fn = true, -- CSS rgb() and rgba() functions
      hsl_fn = false, -- CSS hsl() and hsla() functions
      css = false, -- Enable all CSS features
      css_fn = false, -- Enable all CSS *functions*
      mode = "background", -- foreground | background | virtualtext
      tailwind = false,
      sass = { enable = false, parsers = { "css" } },
      virtualtext = "■",
      always_update = false,
    })
  end,
}

