-- Define Commands
local utils = require('smoothcursor.utils')

vim.api.nvim_create_user_command('SmoothCursorStart', utils.smoothcursor_start, {})

vim.api.nvim_create_user_command('SmoothCursorStop', function(args)
  if #args.fargs > 1 then
    vim.notify("Too many arguments. '--keep-signs' or empty are allowed.", vim.log.levels.ERROR)
    return
  end
  if args.fargs[1] == nil then
    utils.smoothcursor_stop()
  elseif args.fargs[1] == '--keep-signs' then
    utils.smoothcursor_stop(false)
  else
    vim.notify([[bad argument, "--keep-signs" or empty]], vim.log.levels.ERROR)
  end
end, {
  nargs = '*',
  complete = function()
    return { '--keep-signs' }
  end,
})

vim.api.nvim_create_user_command('SmoothCursorToggle', utils.smoothcursor_toggle, {})

vim.api.nvim_create_user_command('SmoothCursorFancyOn', utils.smoothcursor_fancy_on, {})

vim.api.nvim_create_user_command('SmoothCursorFancyOff', utils.smoothcursor_fancy_off, {})

vim.api.nvim_create_user_command('SmoothCursorFancyToggle', utils.smoothcursor_fancy_toggle, {})

vim.api.nvim_create_user_command('SmoothCursorStatus', function()
  vim.notify(string.format('Status: %s', tostring(utils.smoothcursor_status())))
end, {})

vim.api.nvim_create_user_command('SmoothCursorDeleteSigns', utils.smoothcursor_delete_signs, {})

vim.api.nvim_create_user_command('SmoothCursorDebug', require('smoothcursor.debug').debug, {})
