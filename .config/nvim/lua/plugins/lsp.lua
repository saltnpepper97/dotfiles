return {
  "williamboman/mason.nvim",
  dependencies = {
    -- Mason & LSP
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    -- Completion
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    -- Snippets
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "rafamadriz/friendly-snippets",
    -- Icons in completion
    "onsails/lspkind.nvim",
    -- Treesitter
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
    },
  },
  config = function()
    -- Mason
    require("mason").setup()
    -- Mason-LSPConfig
    require("mason-lspconfig").setup({
      ensure_installed = {
        "lua_ls",
        "pyright",
        "ts_ls",
        "bashls",
        "jsonls",
        "rust_analyzer",
        "svelte",
        "zls",
        "clangd"
      },
      automatic_installation = true,
    })

    -- Simple LSP Keybinds (attached when LSP starts)
    local function setup_keybinds(bufnr)
      local opts = { buffer = bufnr, noremap = true, silent = true }
      
      -- Navigation
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)           -- Go to Definition
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)           -- Go to References
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)                 -- Hover info
      
      -- Actions
      vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)        -- Rename
      vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, opts)   -- Code Actions
      vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, opts)        -- Format
      
      -- Diagnostics
      vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts) -- Show Error
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)         -- Next Error
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)         -- Previous Error
    end

    -- LSP Capabilities
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    
    -- LSP Servers
    local lspconfig = require("lspconfig")
    local servers = {
      "lua_ls",
      "pyright",
      "ts_ls",
      "bashls",
      "jsonls",
      "rust_analyzer",
      "svelte",
      "zls",
      "clangd"
    }
    
    for _, server in ipairs(servers) do
      lspconfig[server].setup({
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          setup_keybinds(bufnr)
        end,
      })
    end
    
    -- nvim-cmp
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    require("luasnip.loaders.from_vscode").lazy_load()
    local lspkind = require("lspkind")
    cmp.setup({
      snippet = {
        expand = function(args) luasnip.lsp_expand(args.body) end,
      },
      mapping = cmp.mapping.preset.insert({
        -- Simple navigation
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
        -- Accept completion
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        -- Trigger completion manually
        ["<C-Space>"] = cmp.mapping.complete(),
        -- Close completion
        ["<Esc>"] = cmp.mapping.abort(),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
      }),
      formatting = {
        format = lspkind.cmp_format({
          mode = "symbol_text",
          maxwidth = 50,
          ellipsis_char = "...",
        }),
      },
    })
    -- Treesitter with auto-install
    require("nvim-treesitter.configs").setup({
      ensure_installed = {}, -- empty = let it auto-install on demand
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
