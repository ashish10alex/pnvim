-- disable netrw at the very start of your init.lua
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = " "

-- Enable exhaustive tab completion
vim.o.wildmode = "longest,list,full"
vim.o.wildmenu = true

-- Ignore files
vim.opt.wildignore = {
  "*.pyc",
  "*_build/*",
  "**/coverage/*",
  "**/node_modules/*",
  "**/android/*",
  "**/ios/*",
  "**/.git/*",
}

vim.o.errorbells = false                  -- Disable error bells
vim.o.scrolloff = 10                      -- Smooth scrolling at the bottom
vim.o.spell = true                        -- Enable spell checking
vim.o.spelllang = "en_us"                 -- Set spell checking language
vim.o.encoding = "utf-8"                  -- Set internal encoding to UTF-8
vim.o.hidden = true                       -- Allow switching buffers without saving
vim.o.backup = false                      -- Disable backup files
vim.o.writebackup = false                 -- Disable writebackup files
vim.o.syntax = "on"                       -- Enable syntax highlighting
vim.o.relativenumber = false               -- Disable relative line numbers
vim.o.textwidth = 220                     -- Set text width to 120 characters
vim.o.updatetime = 30                     -- Set update time to 30 milliseconds
vim.o.termguicolors = true                -- Enable true color support
vim.o.tabstop = 4                         -- Set tab stop to 4 spaces
vim.o.softtabstop = 4                     -- Set soft tab stop to 4 spaces
vim.o.shiftwidth = 4                      -- Set shift width to 4 spaces
vim.o.expandtab = true                    -- Expand tabs to spaces
vim.o.smartindent = true                  -- Enable smart indentation
vim.o.number = true                       -- Enable line numbering
vim.o.smartcase = true                    -- Enable smart case search
vim.o.incsearch = true                    -- Enable incremental search
vim.o.hlsearch = true                     -- Enable highlight search
vim.o.ignorecase = true                   -- Enable case-insensitive search
-- vim.o.foldmethod = "indent"               -- Set folding method to indent
-- vim.o.foldlevel = 99                      -- Set initial fold level to 99 (closed)
vim.opt.foldtext = ""
vim.o.clipboard = "unnamedplus"           -- Use system clipboard
vim.o.wrap = false                        -- Disable line wrapping
vim.cmd("highlight Comment cterm=italic") -- Highlight comments in italics

vim.cmd([[
    au BufWinEnter *.sqlx set updatetime=200 | set autoread
    au CursorHold *.sqlx  checktime
]])

-- vim.o.foldenable = false

-- ** Hack to make diagnostics work for CompileDataform **
-- Show line diagnostics automatically in hover window
-- vim.cmd([[
--     autocmd! CursorHold * lua vim.diagnostic.open_float({severity=vim.diagnostic.severity.ERROR}, {focus = false})
-- ]])

-- Doing this as the lsp one was not working as we donot have a lsp for sql yet!
vim.cmd([[
    nnoremap <silent> ]e <cmd>lua vim.diagnostic.goto_next({popup_opts = {focusable=false}})<CR>
    nnoremap <silent> [e <cmd>lua vim.diagnostic.goto_prev({popup_opts = {focusable=false}})<CR>
]])


-- Easy printing of lua tables
P = function(v)
  print(vim.inspect(v))
  return v
end


-- Delete to blackhole register if line is empty
-- function Smart_dd()
-- 	if vim.api.nvim_get_current_line():match("^%s*$") then
-- 		return '"_dd'
-- 	else
-- 		return "dd"
-- 	end
-- end
-- vim.api.nvim_set_keymap('n', 'dd', 'v:lua.Smart_dd()', {expr = true, noremap = true})


-- Toogle quickfix list
function QuickFixToggle()
	local qf_exists = false
	for _, win in pairs(vim.fn.getwininfo()) do
		if win["quickfix"] == 1 then
			qf_exists = true
		end
	end
	if qf_exists == true then
		vim.cmd("cclose")
		return
	end
	if not vim.tbl_isempty(vim.fn.getqflist()) then
		vim.cmd("copen")
	end
end
vim.api.nvim_set_keymap('n', '<leader>q', ':lua QuickFixToggle()<CR>', {noremap = true})

