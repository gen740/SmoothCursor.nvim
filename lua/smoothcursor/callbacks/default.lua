local callback = require('smoothcursor.callbacks')
local buffer = callback.buffer

local config = require('smoothcursor.config')
local debug_callback = require('smoothcursor.debug').debug_callback

local last_positions = {}

-- Default cursor callback. buffer["prev"] is always integer
local function sc_default()
  if not callback.is_enabled() then
    return
  end

  buffer['.'] = vim.fn.line('.')
  if buffer['prev'] == nil then
    buffer['prev'] = buffer['.']
  end
  buffer['diff'] = buffer['prev'] - buffer['.']
  buffer['diff'] = math.min(buffer['diff'], vim.fn.winheight(0) * 2)
  buffer['w0'] = vim.fn.line('w0')
  buffer['w$'] = vim.fn.line('w$')

  if math.abs(buffer['diff']) > config.value.threshold then
    local counter = 1
    callback.sc_timer:post(function()
      buffer['.'] = vim.fn.line('.')
      if buffer['prev'] == nil then
        buffer['prev'] = buffer['.']
      end
      -- For <c-f>/<c-b> movement. buffer["prev"] has room for half screen.
      buffer['w0'] = vim.fn.line('w0')
      buffer['w$'] = vim.fn.line('w$')
      buffer['prev'] = math.max(buffer['prev'], buffer['w0'] - math.floor(vim.fn.winheight(0) / 2))
      buffer['prev'] = math.min(buffer['prev'], buffer['w$'] + math.floor(vim.fn.winheight(0) / 2))
      buffer['diff'] = buffer['prev'] - buffer['.']
      buffer['prev'] = buffer['prev']
        - (
          (buffer['diff'] > 0) and math.ceil(buffer['diff'] / 100 * config.value.speed)
          or math.floor(buffer['diff'] / 100 * config.value.speed)
        )
      buffer:push_front(buffer['prev'])
      -- Replace Signs
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

    for name, line in pairs(last_positions) do
      if line ~= nil then
        callback.place_sign(line, 'smoothcursor_' .. name)
      end
    end

    debug_callback(buffer, { 'Jump: False' })
  end
end

return {
  sc_default = sc_default,
  last_positions = last_positions,
}
