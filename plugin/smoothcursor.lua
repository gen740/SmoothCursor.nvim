-- Define Commands
local utils = require('smoothcursor.utils')

vim.api.nvim_create_user_command('SmoothCursorStart', utils.smoothcursor_start, {})
vim.api.nvim_create_user_command('SmoothCursorStop', utils.smoothcursor_stop, {})
vim.api.nvim_create_user_command('SmoothCursorToggle', utils.smoothcursor_toggle, {})

vim.api.nvim_create_user_command('SmoothCursorFreezeOn', utils.smoothcursor_freeze_on, {})
vim.api.nvim_create_user_command('SmoothCursorFreezeOff', utils.smoothcursor_freeze_off, {})
vim.api.nvim_create_user_command('SmoothCursorFreezeToggle', utils.smoothcursor_freeze_toggle, {})

vim.api.nvim_create_user_command('SmoothCursorFancyOn', utils.smoothcursor_fancy_on, {})
vim.api.nvim_create_user_command('SmoothCursorFancyOff', utils.smoothcursor_fancy_off, {})
vim.api.nvim_create_user_command('SmoothCursorFancyToggle', utils.smoothcursor_fancy_toggle, {})

vim.api.nvim_create_user_command('SmoothCursorStatus', function()
  vim.notify(string.format('Status: %s', tostring(utils.smoothcursor_status())))
end, {})

vim.api.nvim_create_user_command('SmoothCursorDeleteSigns', utils.smoothcursor_delete_signs, {})
