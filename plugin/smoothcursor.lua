-- Define Commands
vim.api.nvim_create_user_command('SmoothCursorStart', require("smoothcursor.utils").smoothcursor_start, {})
vim.api.nvim_create_user_command('SmoothCursorStop', require("smoothcursor.utils").smoothcursor_stop, {})
vim.api.nvim_create_user_command('SmoothCursorToggle', require("smoothcursor.utils").smoothcursor_toggle, {})
vim.api.nvim_create_user_command('SmoothCursorStatus', function()
    print(string.format("Status: %s", tostring(require("smoothcursor.utils").smoothcursor_status())))
end, {})
vim.api.nvim_create_user_command('SmoothCursorDeleteSigns', require("smoothcursor.utils").smoothcursor_delete_signs, {})
