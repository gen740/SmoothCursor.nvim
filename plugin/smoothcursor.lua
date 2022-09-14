vim.api.nvim_create_user_command('SmoothCursorStart', require("smoothcursor.utils").smoothcursor_start, {})
vim.api.nvim_create_user_command('SmoothCursorStop', require("smoothcursor.utils").smoothcursor_stop, {})
vim.api.nvim_create_user_command('SmoothCursorToggle', require("smoothcursor.utils").smoothcursor_toggle, {})


vim.api.nvim_create_namespace('SmoothCursor')
vim.api.nvim_set_hl(0, 'SmoothCursor', { bg = nil, fg = "#FFD400" })
