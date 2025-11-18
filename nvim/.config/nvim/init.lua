-- Suppress lspconfig deprecation warnings
vim.deprecate = function() end

-- =============================================================================
-- LAZY.NVIM BOOTSTRAP
-- =============================================================================
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- =============================================================================
-- CORE OPTIONS
-- =============================================================================
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.termguicolors = true
vim.opt.completeopt = 'menu,menuone,noselect'
vim.diagnostic.config({
  virtual_text = { severity = { min = vim.diagnostic.severity.WARN } },
  signs = true,
  underline = true,
  update_in_insert = false,
})

-- =============================================================================
-- KEYMAPS
-- =============================================================================
local map = vim.keymap.set
map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')
map('n', '<S-l>', '<cmd>bnext<CR>')
map('n', '<S-h>', '<cmd>bprevious<CR>')
map('n', '<leader>bd', '<cmd>bdelete<CR>')
map('v', '<', '<gv')
map('v', '>', '>gv')
map('n', '<A-j>', '<cmd>m .+1<CR>==')
map('n', '<A-k>', '<cmd>m .-2<CR>==')
map('v', '<A-j>', ":m '>+1<CR>gv=gv")
map('v', '<A-k>', ":m '<-2<CR>gv=gv")
map('n', '<leader>w', '<cmd>w<CR>')
map('n', '<leader>q', '<cmd>q<CR>')
map('n', '[d', vim.diagnostic.goto_prev)
map('n', ']d', vim.diagnostic.goto_next)
map('n', '<leader>d', vim.diagnostic.open_float)

-- =============================================================================
-- PLUGINS
-- =============================================================================
require('lazy').setup({
  { 'catppuccin/nvim', name = 'catppuccin', priority = 1000, config = function() vim.cmd.colorscheme('catppuccin-mocha') end },
  { 'nvim-lualine/lualine.nvim', opts = { options = { theme = 'catppuccin', component_separators = '│', section_separators = '' } } },
  { 'nvim-telescope/telescope.nvim', cmd = 'Telescope', dependencies = { 'nvim-lua/plenary.nvim' }, keys = { { '<leader>ff', '<cmd>Telescope find_files<cr>' }, { '<leader>fg', '<cmd>Telescope live_grep<cr>' }, { '<leader>fb', '<cmd>Telescope buffers<cr>' }, { '<leader>fh', '<cmd>Telescope help_tags<cr>' } }, opts = { defaults = { path_display = { 'truncate' }, mappings = { i = { ['<C-j>'] = 'move_selection_next', ['<C-k>'] = 'move_selection_previous' } } } } },
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate', event = { 'BufReadPost', 'BufNewFile' }, opts = { ensure_installed = { 'c', 'cpp', 'python', 'lua', 'bash', 'asm' }, highlight = { enable = true }, indent = { enable = true } }, config = function(_, opts) require('nvim-treesitter.configs').setup(opts) end },
  { 'williamboman/mason.nvim', cmd = 'Mason', build = ':MasonUpdate', config = function() require('mason').setup() end },
  { 'neovim/nvim-lspconfig', event = { 'BufReadPre', 'BufNewFile' }, dependencies = { 'williamboman/mason.nvim', 'hrsh7th/cmp-nvim-lsp' } },
})
