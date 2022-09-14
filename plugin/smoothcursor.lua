-- _G.SmoothCursorStart = function() require("smoothcursor.utils").smoothcursor_start() end
-- _G.SmoothCursorStop = function() require("smoothcursor.utils").smoothcursor_stop() end
-- _G.SmoothCursorToggle = function() require("smoothcursor.utils").smoothcursor_toggle() end

vim.api.nvim_create_user_command('SmoothCursorStart', require("smoothcursor.utils").smoothcursor_start, {})
vim.api.nvim_create_user_command('SmoothCursorStop', require("smoothcursor.utils").smoothcursor_stop, {})
vim.api.nvim_create_user_command('SmoothCursorToggle', require("smoothcursor.utils").smoothcursor_toggle, {})
