local callback = require('smoothcursor.callbacks')
local buffer = callback.buffer

local config = require('smoothcursor.config')
local debug_callback = require('smoothcursor.debug').debug_callback

-- Exponential corsor callback. buffer["prev"] is no longer integer.
local function sc_exp()
  if not callback.is_enabled() then
    return
  end
  buffer['.'] = vim.fn.line('.')
  if buffer['prev'] == nil then
    buffer['prev'] = buffer['.']
  end
  local absolute_diff = math.abs(buffer['prev'] - buffer['.'])
  local relative_diff = math.min(absolute_diff, vim.fn.winheight(0) * 2)
  buffer['w0'] = vim.fn.line('w0')
  buffer['w$'] = vim.fn.line('w$')

  if
    relative_diff > config.value.threshold
    and (config.value.max_threshold == nil or absolute_diff <= config.value.max_threshold)
  then
    local counter = 1
    callback.sc_timer:post(function()
      buffer['.'] = vim.fn.line('.')
      if buffer['prev'] == nil then
        buffer['prev'] = buffer['.']
      end
      -- For <c-f>/<c-b> movement. buffer["prev"] has room for half screen.
      buffer['w0'] = vim.fn.line('w0')
      buffer['w$'] = vim.fn.line('w$')
      buffer['prev'] = math.max(buffer['prev'], buffer['w0'] - vim.fn.winheight(0) / 2)
      buffer['prev'] = math.min(buffer['prev'], buffer['w$'] + vim.fn.winheight(0) / 2)
      buffer['diff'] = buffer['prev'] - buffer['.']
      buffer['prev'] = buffer['prev'] - buffer['diff'] / 100 * config.value.speed
      if math.abs(buffer['diff']) < 0.5 then
        buffer['prev'] = buffer['.']
      end
      buffer:push_front(buffer['prev'])
      callback.replace_signs()
      counter = counter + 1
      debug_callback(buffer, { 'Jump: True' })
      -- Timer management
      if
        counter > (config.value.timeout / config.value.intervals)
        or (buffer['diff'] == 0 and buffer:is_stay_still())
      then
        if not callback.fancy_head_exists() then
          callback.unplace_signs()
        end
        callback.sc_timer:abort()
      end
    end)
  else
    buffer['prev'] = buffer['.']
    buffer:all(buffer['.'])
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
