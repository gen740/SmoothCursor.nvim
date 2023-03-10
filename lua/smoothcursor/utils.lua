local sc = {}
local smoothcursor_started = false
local callback = require('smoothcursor.callbacks')
local configs = require('smoothcursor.config').config
local init = require('smoothcursor.init')
local buffer_leaved = false

--@param init_fire boolean
sc.smoothcursor_start = function(init_fire)
  if init_fire == nil then
    init_fire = true
  end
  if smoothcursor_started then
    return
  end

  vim.api.nvim_create_augroup('SmoothCursor', { clear = true })

  vim.api.nvim_create_autocmd({ 'BufEnter' }, {
    group = 'SmoothCursor',
    callback = function()
      callback.switch_buf()
      callback.set_buffer_to_prev_pos()
      callback.lazy_detect()
      vim.defer_fn(callback.sc_callback, 0) -- for lazy filetype detect
    end,
  })

  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
    group = 'SmoothCursor',
    callback = function()
      -- leaving floating window does not fire BufEnter
      -- the first call after buffer leave should switch_buffer
      if buffer_leaved then
        callback.switch_buf()
        buffer_leaved = false
      end
      callback.sc_callback()
    end,
  })

  vim.api.nvim_create_autocmd({ 'BufLeave', 'WinLeave' }, {
    group = 'SmoothCursor',
    callback = function()
      buffer_leaved = true
      callback.unplace_signs(true)
      callback.lazy_detect()
      if configs.flyin_effect == 'bottom' then
        callback.buffer_set_all(vim.fn.line('$'))
      elseif configs.flyin_effect == 'top' then
        callback.buffer_set_all(0)
      end
    end,
  })

  smoothcursor_started = true
  if init_fire then
    callback.sc_callback()
  end
end

--@param erase_signs bool|nil
sc.smoothcursor_stop = function(erase_signs)
  erase_signs = (erase_signs == nil) and true
  if not smoothcursor_started then
    return
  end
  if erase_signs then
    callback.unplace_signs()
  end
  vim.api.nvim_del_augroup_by_name('SmoothCursor')
  smoothcursor_started = false
end

sc.smoothcursor_toggle = function()
  if smoothcursor_started then
    sc.smoothcursor_stop()
  else
    sc.smoothcursor_start()
  end
end

sc.smoothcursor_status = function()
  return smoothcursor_started
end

sc.smoothcursor_delete_signs = function()
  callback.unplace_signs()
end

sc.with_smoothcursor = function(func, ...)
  callback.buffer_set_all()
  func(...)
  if callback.sc_callback == nil then
    vim.notify('Smoothcursor.setup has not been called, Please configure in your config file')
    return
  end
  callback.sc_callback()
end

---@param arg boolean
sc.smoothcursor_fancy_set = function(arg)
  if arg == nil then
    arg = false
  end
  sc.smoothcursor_stop()
  configs.fancy.enable = arg
  init.init_and_start()
  callback.buffer_set_all()
end

sc.smoothcursor_fancy_toggle = function()
  sc.smoothcursor_fancy_set(not configs.fancy.enable)
end

sc.smoothcursor_fancy_on = function()
  sc.smoothcursor_fancy_set(true)
end

sc.smoothcursor_fancy_off = function()
  sc.smoothcursor_fancy_set(false)
end

sc.set_smoothcursor_highlight = function()
  if vim.api.nvim_get_namespaces().SmoothCursor == nil then
    vim.api.nvim_create_namespace('SmoothCursor')
    vim.api.nvim_create_namespace('SmoothCursorRed')
    vim.api.nvim_create_namespace('SmoothCursorOrange')
    vim.api.nvim_create_namespace('SmoothCursorYellow')
    vim.api.nvim_create_namespace('SmoothCursorGreen')
    vim.api.nvim_create_namespace('SmoothCursorAqua')
    vim.api.nvim_create_namespace('SmoothCursorBlue')
    vim.api.nvim_create_namespace('SmoothCursorPurple')
  end
  vim.api.nvim_set_hl(0, 'SmoothCursor', { bg = nil, fg = '#FFD400', default = true })
  vim.api.nvim_set_hl(0, 'SmoothCursorRed', { bg = nil, fg = '#FF0000', default = true })
  vim.api.nvim_set_hl(0, 'SmoothCursorOrange', { bg = nil, fg = '#FFA500', default = true })
  vim.api.nvim_set_hl(0, 'SmoothCursorYellow', { bg = nil, fg = '#FFFF00', default = true })
  vim.api.nvim_set_hl(0, 'SmoothCursorGreen', { bg = nil, fg = '#008000', default = true })
  vim.api.nvim_set_hl(0, 'SmoothCursorAqua', { bg = nil, fg = '#00FFFF', default = true })
  vim.api.nvim_set_hl(0, 'SmoothCursorBlue', { bg = nil, fg = '#0000FF', default = true })
  vim.api.nvim_set_hl(0, 'SmoothCursorPurple', { bg = nil, fg = '#800080', default = true })
end

return sc
