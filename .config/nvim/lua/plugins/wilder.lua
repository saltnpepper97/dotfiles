return {
  "gelguy/wilder.nvim",
  config = function()
    local wilder = require('wilder')
    wilder.setup({modes = {':', '/', '?'}})

    -- Disable Python remote plugin
    wilder.set_option('use_python_remote_plugin', 0)

    wilder.set_option('pipeline', {
      wilder.branch(
        wilder.cmdline_pipeline({
          -- Use vim's built-in fuzzy filter instead
          fuzzy = 1,
        }),
        wilder.vim_search_pipeline()
      ),
    })

    wilder.set_option('renderer', wilder.popupmenu_renderer({
      -- Disable transparency
      pumblend = 20,
      max_height = '75%',      -- max height of the palette
      min_height = 0,          -- set to the same as 'max_height' for a fixed height window
      reverse = 0,             -- set to 1 to reverse the order of the list
    }))
  end,
}
