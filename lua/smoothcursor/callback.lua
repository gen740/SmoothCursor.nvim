local config = require('smoothcursor.default')
local sc_debug = require('smoothcursor.debug')
local debug_callback = sc_debug.debug_callback
local lazy_redetect_filetype = false

-- Buffer specific list
BList = {}

function BList.new(length)
  local obj = {
    buffer = {},
    length = length,
    bufnr = 1, -- chach bufnr
    push_front = function(self, data)
      table.insert(self, 1, data)
      table.remove(self, self.length + 1)
    end,
    switch_buf = function(self)
      self.bufnr = vim.fn.bufnr()
      sc_debug.buf_switch_counter = sc_debug.buf_switch_counter + 1
    end,
    all = function(self, value)
      for i = 1, self.length, 1 do
        self[i] = value
      end
    end,
    is_stay_still = function(self)
      local first_val = self[1]
      for i = 2, self.length do
        if first_val ~= self[i] then
          return false
        end
      end
      return true
    end,
  }
  for _ = 1, obj.length, 1 do
    table.insert(obj, 1, 0)
  end
  return setmetatable(obj, {
    __index = function(t, k)
      if t.buffer[t.bufnr] == nil then
        t.buffer[t.bufnr] = {}
      end
      return t.buffer[t.bufnr][k]
    end,
    __newindex = function(t, k, v)
      if t.buffer[t.bufnr] == nil then
        t.buffer[t.bufnr] = {}
      end
      t.buffer[t.bufnr][k] = v
    end,
  })
end

local buffer = BList.new(1)

local function init()
  if config.default_args.fancy.enable then
    buffer = BList.new(#config.default_args.fancy.body + 1)
  else
    buffer = BList.new(1)
  end
end

---@param value integer | nil
local function buffer_set_all(value)
  if value == nil then
    value = vim.fn.getcurpos(vim.fn.win_getid())[2]
  end
  buffer['prev'] = value
  buffer:all(value)
  debug_callback(buffer, { 'Buffer Reset' }, function()
    sc_debug.reset_counter = sc_debug.reset_counter + 1
  end)
end

-- sc_timer --------------------------------------------------------------------
-- Hold unique uv timer.
local uv = vim.loop

local sc_timer = {
  is_running = false,
  timer = uv.new_timer(),
}

-- post if timer is stop
---@param func function
function sc_timer:post(func)
  if self.is_runnig then
    return
  end
  uv.timer_start(self.timer, 0, config.default_args.intervals, vim.schedule_wrap(func))
  self.is_running = true
end

function sc_timer:abort()
  self.timer:stop()
  self.is_running = false
end

--- @param with_timer_stop? boolean
local function unplace_signs(with_timer_stop)
  if with_timer_stop == true then
    sc_timer:abort()
  end
  vim.fn.sign_unplace('*', { buffer = vim.fn.bufname(), id = config.default_args.cursorID })
  sc_debug.unplace_signs_conuter = sc_debug.unplace_signs_conuter + 1
end

-- place 'name' sign to the 'position'
---@param position number
---@param name string
local function place_sign(position, name)
  position = math.floor(position + 0.5)
  if position < buffer['w0'] or position > buffer['w$'] then
    return
  end
  if name ~= nil then
    vim.fn.sign_place(
      config.default_args.cursorID,
      'SmoothCursor',
      name,
      vim.fn.bufname(),
      { lnum = position, priority = config.default_args.priority }
    )
  end
end

local function fancy_head_exists()
  -- if it is not fancy mode Head is always set
  if not config.default_args.fancy.enable then
    return true
  end
  return config.default_args.fancy.head ~= nil and config.default_args.fancy.head.cursor ~= nil
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
  if config.default_args.fancy.tail ~= nil and config.default_args.fancy.tail.cursor ~= nil then
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
    config.default_args.disable_float_win == true
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
  if config.default_args.enabled_filetypes == nil then
    config.default_args.disabled_filetypes = config.default_args.disabled_filetypes or {}
    buffer['enabled'] = true
    for _, value in ipairs(config.default_args.disabled_filetypes) do
      if now_ft == value then
        buffer['enabled'] = false
      end
    end
  else
    buffer['enabled'] = false
    for _, value in ipairs(config.default_args.enabled_filetypes) do
      if now_ft == value then
        buffer['enabled'] = true
      end
    end
  end
  return buffer['enabled']
end

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

local function enable_smoothcursor()
  buffer['enabled'] = true
end

local function disable_smoothcursor()
  buffer['enabled'] = true
end

-- Exponential corsor callback. buffer["prev"] is no longer integer.
local function sc_exp()
  if not is_enabled() then
    return
  end
  local cursor_now = vim.fn.getcurpos(vim.fn.win_getid())[2]
  if buffer['prev'] == nil then
    buffer['prev'] = cursor_now
  end
  buffer['diff'] = buffer['prev'] - cursor_now
  buffer['diff'] = math.min(buffer['diff'], vim.fn.winheight(0) * 2)
  buffer['w0'] = vim.fn.line('w0')
  buffer['w$'] = vim.fn.line('w$')
  if math.abs(buffer['diff']) > config.default_args.threshold then
    local counter = 1
    sc_timer:post(function()
      cursor_now = vim.fn.getcurpos(vim.fn.win_getid())[2]
      if buffer['prev'] == nil then
        buffer['prev'] = cursor_now
      end
      -- For <c-f>/<c-b> movement. buffer["prev"] has room for half screen.
      buffer['w0'] = vim.fn.line('w0')
      buffer['w$'] = vim.fn.line('w$')
      buffer['prev'] = math.max(buffer['prev'], buffer['w0'] - vim.fn.winheight(0) / 2)
      buffer['prev'] = math.min(buffer['prev'], buffer['w$'] + vim.fn.winheight(0) / 2)
      buffer['diff'] = buffer['prev'] - cursor_now
      buffer['prev'] = buffer['prev'] - buffer['diff'] / 100 * config.default_args.speed
      if math.abs(buffer['diff']) < 0.5 then
        buffer['prev'] = cursor_now
      end
      buffer:push_front(buffer['prev'])
      replace_signs()
      counter = counter + 1
      debug_callback(buffer, { 'Jump: True' })
      -- Timer management
      if
        counter > (config.default_args.timeout / config.default_args.intervals)
        or (buffer['diff'] == 0 and buffer:is_stay_still())
      then
        if not fancy_head_exists() then
          unplace_signs()
        end
        sc_timer:abort()
      end
    end)
  else
    buffer['prev'] = cursor_now
    buffer:all(cursor_now)
    unplace_signs()
    if fancy_head_exists() then
      place_sign(buffer['prev'], 'smoothcursor')
    end
    debug_callback(buffer, { 'Jump: False' })
  end
end

return {
  buffer = buffer,
  init = init,
  is_enabled = is_enabled,
  fancy_head_exists = fancy_head_exists,
  sc_timer = sc_timer,
  sc_callback_exp = sc_exp,
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
  enable_smoothcursor = enable_smoothcursor,
  disable_smoothcursor = disable_smoothcursor,
  lazy_detect = function()
    lazy_redetect_filetype = true
  end,
  switch_buf = function()
    buffer:switch_buf()
  end,
}
