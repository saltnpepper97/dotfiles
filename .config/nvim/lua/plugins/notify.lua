return {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  opts = {
    -- Animation style (try "slide" to avoid darkening fade effects)
    stages = "slide",
    -- Timeout for notifications
    timeout = 3000,
    -- Background colour
    background_colour = "#000000",
    -- Icons for different log levels
    icons = {
      ERROR = "",
      WARN = "",
      INFO = "",
      DEBUG = "",
      TRACE = "✎",
    },
    -- Minimum width and max width for notification window
    minimum_width = 50,
    max_width = 80,
    -- Max height for notification window
    max_height = 10,
    -- Render function (can be "default", "minimal", "simple", "compact")
    render = "default",
    -- Position of notifications ("top_left", "top_right", "bottom_left", "bottom_right")
    top_down = true,
  },
  config = function(_, opts)
    local notify = require("notify")
    notify.setup(opts)
    
    -- Set nvim-notify as the default notification handler
    vim.notify = notify
    
    -- Optional: Add some keymaps for managing notifications
    vim.keymap.set("n", "<leader>nd", function()
      notify.dismiss({ silent = true, pending = true })
    end, { desc = "Dismiss all notifications" })
    
    -- Optional: Show notification history
    vim.keymap.set("n", "<leader>nh", function()
      require("telescope").extensions.notify.notify()
    end, { desc = "Show notification history" })
  end,
}
