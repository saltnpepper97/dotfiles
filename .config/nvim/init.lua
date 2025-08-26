--
--   ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
--   ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
--   ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
--   ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
--   ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
--   ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--                                                 


-- ==============================
-- Neovim init.lua — sane defaults
-- ==============================

-- Short aliases for convenience
local g   = vim.g     -- Global variables
local o   = vim.o     -- Global options
local opt = vim.opt   -- Scoped/buffer/window options
local cmd = vim.cmd   -- Execute Vim commands

-- ------------------------------
-- Leaders (set first)
-- ------------------------------
g.mapleader = " "             -- Space as leader key
g.maplocalleader = " "

-- ------------------------------
-- General
-- ------------------------------
o.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true           -- persistent undo
opt.undolevels = 10000        -- more undo levels
opt.undoreload = 10000        -- save whole buffer for undo when reloading

opt.clipboard = "unnamedplus" -- Use system clipboard
opt.mouse = "a"               -- Enable mouse
opt.termguicolors = true      -- True color support
opt.confirm = true            -- Confirm to save changes before exiting modified buffer

-- ------------------------------
-- UI
-- ------------------------------
opt.number = true             -- Show line numbers
opt.relativenumber = false    -- Relative line numbers
opt.cursorline = true         -- Highlight current line
opt.signcolumn = "yes"        -- Always show sign column
opt.wrap = false              -- No soft wrap by default
opt.scrolloff = 4             -- Context lines above/below cursor
opt.sidescrolloff = 8
opt.pumheight = 10            -- Popup menu height

opt.showmode = false          -- Don't show -- INSERT -- mode
opt.laststatus = 3            -- Global statusline
opt.conceallevel = 2          -- Hide * markup for bold and italic, but not markers with substitutions

-- ------------------------------
-- Tabs & Indentation
-- ------------------------------
opt.expandtab = true          -- Use spaces instead of tabs
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.smartindent = true
opt.breakindent = true        -- Enable break indent

-- ------------------------------
-- Searching
-- ------------------------------
opt.ignorecase = true         -- Ignore case by default
opt.smartcase = true          -- But be smart about it
opt.incsearch = true
opt.hlsearch = true
opt.inccommand = "nosplit"    -- Preview incremental substitute

-- ------------------------------
-- Splits
-- ------------------------------
opt.splitbelow = true
opt.splitright = true

-- ------------------------------
-- Performance
-- ------------------------------
opt.updatetime = 250          -- Faster completion (default 4000ms)
opt.timeoutlen = 300          -- Time to wait for mapped sequence (was 500)
opt.redrawtime = 10000        -- Allow more time for loading syntax on large files

-- ------------------------------
-- File handling
-- ------------------------------
opt.autowrite = true          -- Automatically write file when switching buffers
opt.autoread = true           -- Automatically read file when changed outside of vim

-- ------------------------------
-- Misc
-- ------------------------------
-- Better command-line completion
opt.wildmode = "longest:full,full"
opt.completeopt = "menu,menuone,noselect"

-- Shorter messages
opt.shortmess:append({ W = true, I = true, c = true, C = true })

-- ------------------------------
-- Basic keymaps
-- ------------------------------
-- Clear search with <esc>
vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Leader keymaps
vim.keymap.set("n", "<leader>q", "<cmd>qa<cr>", { desc = "Quit all" })
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
vim.keymap.set("n", "<leader>wq", "<cmd>wq<cr>", { desc = "Save and quit" })
vim.keymap.set("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "No Highlight" })
vim.keymap.set("n", "<leader>cc", ":%y+<cr>", { desc = "Copy entire file" })
vim.keymap.set("n", "<leader>vv", "ggVG\"+p", { desc = "Paste clipboard over entire file" })

-- Better up/down
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

-- Resize window using <ctrl> arrow keys
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })


-- ------------------------------
-- Autocommands
-- ------------------------------

-- Highlight on yank/copy
local function augroup(name)
  return vim.api.nvim_create_augroup("neovim_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Per-filetype indentation settings
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("indentation"),
  pattern = {
    "html", "css", "scss", "sass", "less",
    "javascript", "typescript", "jsx", "tsx",
    "json", "jsonc", "yaml", "yml",
    "vue", "svelte",
    "vim", "lua",
    "sh", "bash", "zsh",
    "markdown", "text"
  },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("tabs"),
  pattern = { "go", "make" },
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "query",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- ------------------------------
-- Plugin setup
-- ------------------------------
-- Lazy Nvim 💤
require("config.lazy")

-- Theme setup
local neopywal = require("neopywal")
neopywal.setup()
vim.cmd.colorscheme("neopywal")
