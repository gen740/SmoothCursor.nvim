local sc = {}
local smoothcursor_started = false
local callback = require('smoothcursor.callbacks')
local config = require('smoothcursor.config')
local init = require('smoothcursor.init')
local last_positions = require'smoothcursor.last_positions'
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

  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'CmdlineChanged' }, {
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
      if config.value.flyin_effect == 'bottom' then
        callback.buffer['prev'] = vim.fn.line('$')
        callback.buffer_set_all(vim.fn.line('$'))
      elseif config.value.flyin_effect == 'top' then
        callback.buffer_set_all(0)
      end
    end,
  })

  local last_pos_config = config.value.show_last_positions

  if last_pos_config ~= nil then
    -- Please note that casting the buffer numbers to strings is necessary, otherwise
    -- lua will interpret the buffer numbers as array indices
    -- Add / Remove buffers to `last_positions` table
    vim.api.nvim_create_autocmd({ "BufAdd" }, {
      group = 'SmoothCursor',
      callback = function()
        local buffer = vim.fn.bufnr("$")

        last_positions.register_buffer(buffer)
      end
    })
    vim.api.nvim_create_autocmd({ "BufDelete" }, {
      group = 'SmoothCursor',
      callback = function()
        local buffer = vim.api.nvim_get_current_buf()

        last_positions.unregister_buffer(buffer)
      end
    })
    -- If starting into a buffer, the BufEnter event is not fired, but `VimEnter` is.
    vim.api.nvim_create_autocmd({ 'VimEnter' }, {
      group = 'SmoothCursor',
      callback = function()
        local buffer = vim.api.nvim_get_current_buf()

        last_positions.register_buffer(buffer)
      end
    })

    -- Neovim always starts with normal mode, doesn't it?
    local current_mode = "n"

    vim.api.nvim_create_autocmd({ 'ModeChanged' }, {
      group = 'SmoothCursor',
      callback = function()
        local buffer = vim.api.nvim_get_current_buf()
        local mode = vim.api.nvim_get_mode().mode

        local last_pos = last_positions.get_positions(buffer)

        -- if is nil, the current buffer is not a text file (could be floating window for example)
        -- we don't want to set the last position in this case
        if last_pos ~= nil then
          if last_pos_config == "enter" then
            last_positions.set_position(
              buffer,
              mode,
              vim.api.nvim_win_get_cursor(0)
            )
          else
            last_positions.set_position(
              buffer,
              current_mode,
              vim.api.nvim_win_get_cursor(0)
            )

            current_mode = vim.api.nvim_get_mode().mode
          end
        end
      end
    })
  end

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
    callback.unplace_signs(true)
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
  config.value.fancy.enable = arg
  init.init_and_start()
  callback.buffer_set_all()
  callback.sc_callback()
end

sc.smoothcursor_fancy_toggle = function()
  sc.smoothcursor_fancy_set(not config.value.fancy.enable)
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
