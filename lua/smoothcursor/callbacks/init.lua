local config = require('smoothcursor.config')
local sc_debug = require('smoothcursor.debug')
local sc_timer = require('smoothcursor.callbacks.timer')
local buffer = require('smoothcursor.callbacks.buffer').buffer

local function init()
  if config.value.fancy.enable then
    buffer:resize_buffer(#config.value.fancy.body + 1)
  else
    buffer:resize_buffer(1)
  end
end

---@param value? integer
local function buffer_set_all(value)
  if value == nil then
    value = vim.fn.getcurpos(vim.fn.win_getid())[2]
  end
  buffer['prev'] = value
  buffer:all(value)

  -- Debug
  sc_debug.debug_callback(buffer, { 'Buffer Reset' }, function()
    sc_debug.reset_counter = sc_debug.reset_counter + 1
  end)
end

---@param with_timer_stop? boolean
local function unplace_signs(with_timer_stop)
  if with_timer_stop == true then
    sc_timer:abort()
  end
  vim.fn.sign_unplace('*', { buffer = vim.fn.bufname(), id = config.value.cursorID })
  sc_debug.unplace_signs_conuter = sc_debug.unplace_signs_conuter + 1
end

-- place 'name' sign to the 'position'
---@param position number
---@param name? string
local function place_sign(position, name)
  position = math.floor(position + 0.5)
  if position < buffer['w0'] or position > buffer['w$'] then
    return
  end
  if name ~= nil then
    vim.fn.sign_place(
      config.value.cursorID,
      'SmoothCursor',
      name,
      vim.fn.bufname(),
      { lnum = position, priority = config.value.priority }
    )
  end
end

local function fancy_head_exists()
  -- if it is not fancy mode Head is always set
  if not config.value.fancy.enable then
    return true
  end
  return config.value.fancy.head ~= nil and config.value.fancy.head.cursor ~= nil
end

local function replace_signs()
  unplace_signs()
  for i = buffer.length, 2, -1 do
    if
      not (
        (math.max(buffer[i - 1], buffer[i]) < buffer['w0'] - 1)
        or (math.min(buffer[i - 1], buffer[i]) > buffer['w$'] + 1)
      )
    then
      for j = buffer[i - 1], buffer[i], ((buffer[i - 1] - buffer[i] < 0) and 1 or -1) do
        place_sign(j, string.format('smoothcursor_body%d', i - 1))
      end
    end
  end
  if config.value.fancy.tail ~= nil and config.value.fancy.tail.cursor ~= nil then
    place_sign(buffer[buffer.length], 'smoothcursor_tail')
  end
  if fancy_head_exists() then
    place_sign(buffer[1], 'smoothcursor')
  end
end

-- Detect filetype and set the value to buffer['enabled']
local function detect_filetype()
  local now_ft = vim.opt_local.ft['_value']
  if now_ft == nil then
    return false
  end
  if
    config.value.disable_float_win == true
    and vim.api.nvim_win_get_config(vim.fn.win_getid()).relative ~= ''
  then
    buffer['enabled'] = false
    return false
  end
  -- disable on terminal by default
  if vim.bo.bt == 'terminal' then
    buffer['enabled'] = false
    return false
  end
  if config.value.enabled_filetypes == nil then
    config.value.disabled_filetypes = config.value.disabled_filetypes or {}
    buffer['enabled'] = true
    for _, value in ipairs(config.value.disabled_filetypes) do
      if now_ft == value then
        buffer['enabled'] = false
      end
    end
  else
    buffer['enabled'] = false
    for _, value in ipairs(config.value.enabled_filetypes) do
      if now_ft == value then
        buffer['enabled'] = true
      end
    end
  end
  return buffer['enabled']
end

---@type boolean
local lazy_redetect_filetype = false

-- This function cache "enabled" value for each buffer.
-- Return if buffer is enabled SmoothCursor or not
---@return boolean
local function is_enabled()
  if lazy_redetect_filetype then
    if not detect_filetype() then
      sc_timer:abort()
      unplace_signs()
    end
    lazy_redetect_filetype = false
  end
  if buffer['enabled'] == true then
    return true
  elseif buffer['enabled'] == false then
    return false
  end
  return detect_filetype()
end

return {
  buffer = buffer,
  init = init,
  is_enabled = is_enabled,
  fancy_head_exists = fancy_head_exists,
  sc_timer = sc_timer,
  sc_callback = nil,
  unplace_signs = unplace_signs,
  replace_signs = replace_signs,
  place_sign = place_sign,
  buffer_set_all = buffer_set_all,
  detect_filetype = detect_filetype,
  set_buffer_to_prev_pos = function()
    if buffer['enabled'] and buffer['prev'] ~= nil then
      buffer:all(buffer['prev'])
    end
  end,
  lazy_detect = function()
    lazy_redetect_filetype = true
  end,
  switch_buf = function()
    buffer:switch_buf()
  end,
}
