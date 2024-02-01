
local augroup = vim.api.nvim_create_augroup   -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd   -- Create autocommand

-- Highlight on yank
augroup('YankHighlight', { clear = true })

-- Remove whitespace on save
autocmd('BufWritePre', {
  pattern = '',
  command = ":%s/\\s\\+$//e"
})

-- Don't auto commenting new lines
autocmd('BufEnter', {
  pattern = '',
  command = 'set fo-=c fo-=r fo-=o'
})

--Enable slate colorscheme when entering .sqlx files
autocmd('bufenter', {
  pattern = 'temp.sqlx',
  command = "colorscheme sorbet | lua vim.opt.signcolumn = 'no'"
})

-- Revert to orignal colorscheme once I leave temp.sqlx file
autocmd('bufleave', {
  pattern = 'temp.sqlx',
  --  vim.opt.signcolumn = 'no'
  command = 'colorscheme catppuccin | lua vim.opt.signcolumn = "yes"'
})

-- Open file at the last position it was edited earlier
vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Open file at the last position it was edited earlier',
  pattern = '*',
  command = 'silent! normal! g`"zv'
})

-- when entering a file that ends with .sqlfluff set filetype to bash
vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'set filetype to bash when entering a file that ends with .sqlfluff',
  pattern = '*.sqlfluff',
  command = 'set filetype=bash'
})

vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Set filetype to terraform when entering a file that ends with .tfvars',
  pattern = '*.tfvars',
  command = 'set filetype=terraform'
})

