
-- keep cursor unchanged after quiting
vim.api.nvim_create_autocmd("ExitPre", {
	group = vim.api.nvim_create_augroup("Exit", { clear = true }),
	command = "set guicursor=a:ver90",
	desc = "Set cursor back to beam when leaving Neovim.",
})

-- disalbe commenting next line
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "r", "o" })
	end,
})

-- hide cursor in SnacksDashboardOpened
vim.api.nvim_create_autocmd("User", {
	pattern = "SnacksDashboardOpened",
	callback = function()
		vim.cmd([[hi Cursor blend=100]])
		vim.cmd("set guicursor+=a:Cursor/lCursor")
	end,
})

-- unhide cursor in SnacksDashboardClosed
vim.api.nvim_create_autocmd("User", {
	pattern = "SnacksDashboardClosed",
	callback = function()
		vim.cmd([[hi Cursor blend=0]])
		vim.cmd("set guicursor+=a:Cursor/lCursor")
	end,
})


-- enable linebreak for markdown
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown" },
	callback = function()
		vim.opt.linebreak = true
	end,
})
