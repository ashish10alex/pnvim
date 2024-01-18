
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
  command = 'colorscheme slate'
})

-- Revert to orignal colorscheme once I leave temp.sqlx file
autocmd('bufleave', {
  pattern = 'temp.sqlx',
  command = 'colorscheme catppuccin'
})

