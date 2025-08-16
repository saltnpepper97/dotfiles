return {
    "RedsXDD/neopywal.nvim",
    name = "neopywal",
    lazy = false,
    priority = 1000,
    opts = {
        plugins = {
           lazy = true,
           mason = true,
           treesitter = true,
           notify = true,
           lsp = {
                enabled = true,
                virtual_text = {
                    errors = { "bold", "italic" },
                    hints = { "bold", "italic" },
                    information = { "bold", "italic" },
                    ok = { "bold", "italic" },
                    warnings = { "bold", "italic" },
                    unnecessary = { "bold", "italic" },
                },
                underlines = {
                    errors = { "undercurl" },
                    hints = { "undercurl" },
                    information = { "undercurl" },
                    ok = { "undercurl" },
                    warnings = { "undercurl" },
                },
                inlay_hints = {
                    background = true,
                    style = { "bold", "italic" },
                },
            },
        },
    },
}
