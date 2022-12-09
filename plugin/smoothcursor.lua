-- Define Commands
local default_args = require('smoothcursor.default').default_args
local utils = require('smoothcursor.utils')
local init = require('smoothcursor.init')
local callback = require('smoothcursor.callback')

vim.api.nvim_create_user_command('SmoothCursorStart', utils.smoothcursor_start, {})
vim.api.nvim_create_user_command('SmoothCursorStop', utils.smoothcursor_stop, {})
vim.api.nvim_create_user_command('SmoothCursorToggle', utils.smoothcursor_toggle, {})

vim.api.nvim_create_user_command('SmoothCursorFancyOn', function()
  utils.smoothcursor_stop()
  default_args.fancy.enable = true
  init.init_and_start()
  callback.buffer_set_all()
end, {})

vim.api.nvim_create_user_command('SmoothCursorFancyOff', function()
  utils.smoothcursor_stop()
  default_args.fancy.enable = false
  init.init_and_start()
  callback.buffer_set_all()
end, {})

vim.api.nvim_create_user_command('SmoothCursorFancyToggle', function()
  utils.smoothcursor_stop()
  default_args.fancy.enable = not default_args.fancy.enable
  init.init_and_start()
  callback.buffer_set_all()
end, {})

vim.api.nvim_create_user_command('SmoothCursorStatus', function()
  vim.notify(string.format('Status: %s', tostring(utils.smoothcursor_status())))
end, {})

vim.api.nvim_create_user_command('SmoothCursorDeleteSigns', utils.smoothcursor_delete_signs, {})
