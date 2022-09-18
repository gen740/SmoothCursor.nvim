-- Define Commands
vim.api.nvim_create_user_command('SmoothCursorStart', require("smoothcursor.utils").smoothcursor_start, {})
vim.api.nvim_create_user_command('SmoothCursorStop', require("smoothcursor.utils").smoothcursor_stop, {})
vim.api.nvim_create_user_command('SmoothCursorToggle', require("smoothcursor.utils").smoothcursor_toggle, {})
vim.api.nvim_create_user_command('SmoothCursorStatus', function()
    print(string.format("Status: %s", tostring(require("smoothcursor.utils").smoothcursor_status())))
end, {})
vim.api.nvim_create_user_command('SmoothCursorDeleteSigns', require("smoothcursor.utils").smoothcursor_delete_signs, {})

-- Color Schemes
vim.api.nvim_create_namespace('SmoothCursor')
vim.api.nvim_create_namespace('SmoothCursorRed')
vim.api.nvim_create_namespace('SmoothCursorOrange')
vim.api.nvim_create_namespace('SmoothCursorYellow')
vim.api.nvim_create_namespace('SmoothCursorGreen')
vim.api.nvim_create_namespace('SmoothCursorAqua')
vim.api.nvim_create_namespace('SmoothCursorBlue')
vim.api.nvim_create_namespace('SmoothCursorPurple')

--
-- local autocmd = vim.api.nvim_create_autocmd
-- local augroup = vim.api.nvim_create_augroup
--
-- local smoothcursor_set_highlight = function()
-- end
--
-- smoothcursor_set_highlight()
--
-- augroup('SmoothCursorHightlight', { clear = true })
-- autocmd({ 'ColorScheme' }, {
--     group = 'CustomColorScheme',
--     callback = smoothcursor_set_highlight
-- })
