-- ============================================================
--  SnowFoxOS v2 — Neovim Config
-- ============================================================

local opt = vim.opt
local g   = vim.g

-- Basis
opt.number         = true
opt.relativenumber = true
opt.cursorline     = true
opt.signcolumn     = "yes"
opt.wrap           = false
opt.scrolloff      = 8
opt.sidescrolloff  = 8

-- Tabs / Einrückung
opt.tabstop        = 2
opt.shiftwidth     = 2
opt.expandtab      = true
opt.smartindent    = true

-- Suche
opt.ignorecase     = true
opt.smartcase      = true
opt.hlsearch       = false
opt.incsearch      = true

-- Aussehen
opt.termguicolors  = true
opt.background     = "dark"
opt.showmode       = false
opt.laststatus     = 2

-- Clipboard
opt.clipboard      = "unnamedplus"

-- Splits
opt.splitbelow     = true
opt.splitright     = true

-- Backup / Undo
opt.swapfile       = false
opt.backup         = false
opt.undofile       = true
opt.undodir        = vim.fn.expand("~/.local/share/nvim/undo")

-- Leader-Taste
g.mapleader = " "

-- Keymaps
local map = vim.keymap.set
map("n", "<leader>e",  ":Ex<CR>",          { desc = "Explorer" })
map("n", "<leader>w",  ":w<CR>",            { desc = "Speichern" })
map("n", "<leader>q",  ":q<CR>",            { desc = "Schließen" })
map("n", "<leader>h",  ":nohlsearch<CR>",   { desc = "Suche deaktivieren" })
map("n", "<C-h>",      "<C-w>h",            { desc = "Fokus links" })
map("n", "<C-l>",      "<C-w>l",            { desc = "Fokus rechts" })
map("n", "<C-j>",      "<C-w>j",            { desc = "Fokus unten" })
map("n", "<C-k>",      "<C-w>k",            { desc = "Fokus oben" })
map("v", "<",          "<gv",               { desc = "Einrücken links" })
map("v", ">",          ">gv",               { desc = "Einrücken rechts" })
map("n", "<leader>p",  "\"_dP",             { desc = "Einfügen ohne Clipboard zu überschreiben" })

-- Einfaches Farbschema (funktioniert ohne Plugins)
vim.cmd([[
  highlight Normal       guibg=#0a0a0a  guifg=#e0e0e0
  highlight NormalNC     guibg=#0f0f0f  guifg=#888888
  highlight CursorLine   guibg=#1a1a1a
  highlight LineNr       guifg=#444444
  highlight CursorLineNr guifg=#9B59B6  gui=bold
  highlight Comment      guifg=#555555  gui=italic
  highlight Keyword      guifg=#9B59B6  gui=bold
  highlight String       guifg=#2ecc71
  highlight Number       guifg=#E67E22
  highlight Function     guifg=#a29bfe
  highlight Type         guifg=#1abc9c
  highlight StatusLine   guibg=#1a1a1a  guifg=#9B59B6
  highlight VertSplit    guifg=#9B59B6
  highlight Visual       guibg=#2d2040
]])

print("SnowFoxOS Neovim geladen 🦊")
