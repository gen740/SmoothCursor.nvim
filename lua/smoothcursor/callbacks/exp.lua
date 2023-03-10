local callback = require('smoothcursor.callbacks')
local buffer = callback.buffer

local config = require('smoothcursor.config').config
local debug_callback = require('smoothcursor.debug').debug_callback
local sc_timer = require('smoothcursor.timer').sc_timer

-- Exponential corsor callback. buffer["prev"] is no longer integer.
local function sc_exp()
  if not callback.is_enabled() then
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
  if math.abs(buffer['diff']) > config.threshold then
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
      buffer['prev'] = buffer['prev'] - buffer['diff'] / 100 * config.speed
      if math.abs(buffer['diff']) < 0.5 then
        buffer['prev'] = cursor_now
      end
      buffer:push_front(buffer['prev'])
      callback.replace_signs()
      counter = counter + 1
      debug_callback(buffer, { 'Jump: True' })
      -- Timer management
      if
        counter > (config.timeout / config.intervals)
        or (buffer['diff'] == 0 and buffer:is_stay_still())
      then
        if not callback.fancy_head_exists() then
          callback.unplace_signs()
        end
        sc_timer:abort()
      end
    end)
  else
    buffer['prev'] = cursor_now
    buffer:all(cursor_now)
    callback.unplace_signs()
    if callback.fancy_head_exists() then
      callback.place_sign(buffer['prev'], 'smoothcursor')
    end
    debug_callback(buffer, { 'Jump: False' })
  end
end

return {
  sc_exp = sc_exp,
}
