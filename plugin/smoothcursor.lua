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
vim.api.nvim_set_hl(0, 'SmoothCursor', { bg = nil, fg = "#FFD400", default = true })

vim.api.nvim_create_namespace('SmoothCursorRed')
vim.api.nvim_create_namespace('SmoothCursorOrange')
vim.api.nvim_create_namespace('SmoothCursorYellow')
vim.api.nvim_create_namespace('SmoothCursorGreen')
vim.api.nvim_create_namespace('SmoothCursorAqua')
vim.api.nvim_create_namespace('SmoothCursorBlue')
vim.api.nvim_create_namespace('SmoothCursorPurple')

vim.api.nvim_set_hl(0, 'SmoothCursorRed', { bg = nil, fg = '#FFFFFF', default = true })
vim.api.nvim_set_hl(0, 'SmoothCursorRed', { bg = nil, fg = '#FF0000', default = true })
vim.api.nvim_set_hl(0, 'SmoothCursorOrange', { bg = nil, fg = '#FFA500', default = true })
vim.api.nvim_set_hl(0, 'SmoothCursorYellow', { bg = nil, fg = '#FFFF00', default = true })
vim.api.nvim_set_hl(0, 'SmoothCursorGreen', { bg = nil, fg = '#008000', default = true })
vim.api.nvim_set_hl(0, 'SmoothCursorAqua', { bg = nil, fg = '#00FFFF', default = true })
vim.api.nvim_set_hl(0, 'SmoothCursorBlue', { bg = nil, fg = '#0000FF', default = true })
vim.api.nvim_set_hl(0, 'SmoothCursorPurple', { bg = nil, fg = '#800080', default = true })
