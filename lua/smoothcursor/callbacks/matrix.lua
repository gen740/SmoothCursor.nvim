local callback = require('smoothcursor.callbacks')
local buffer = callback.buffer

local config = require('smoothcursor.config').config
local debug_callback = require('smoothcursor.debug').debug_callback

-- stylua: ignore
local matrix_char = {
  'ﾊ', 'ﾐ', 'ﾋ', 'ｰ', 'ｳ', 'ｼ', 'ﾅ', 'ﾓ', 'ﾆ', 'ｻ',
  'ﾜ', 'ﾂ', 'ｵ', 'ﾘ', 'ｱ', 'ﾎ', 'ﾃ', 'ﾏ', 'ｹ', 'ﾒ',
  'ｴ', 'ｶ', 'ｷ', 'ﾑ', 'ﾕ', 'ﾗ', 'ｾ', 'ﾈ', 'ｽ', 'ﾀ',
  'ﾇ', 'ﾍ', '𐌇', '0', '1', '2', '3', '4', '5', '7',
  '8', '9', 'Z', ':', '.', '･', '=', '*', '+', '-',
  '<', '>', '¦', '|', '╌', ' ', '"',
}

local function randomize_signs()
  -- config.fancy.head = matrix_char[math.random(0, #matrix_char)]
  for i = 1, #config.fancy.body, 1 do
    config.fancy.body[i].cursor = matrix_char[math.random(0, #matrix_char)]
  end
  require('smoothcursor.init').define_signs(config)
end

-- Default corsor callback. buffer["prev"] is always integer
local function sc_matrix()
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
    callback.sc_timer:post(function()
      randomize_signs()
      cursor_now = vim.fn.getcurpos(vim.fn.win_getid())[2]
      if buffer['prev'] == nil then
        buffer['prev'] = cursor_now
      end
      -- For <c-f>/<c-b> movement. buffer["prev"] has room for half screen.
      buffer['w0'] = vim.fn.line('w0')
      buffer['w$'] = vim.fn.line('w$')
      buffer['prev'] = math.max(buffer['prev'], buffer['w0'] - math.floor(vim.fn.winheight(0) / 2))
      buffer['prev'] = math.min(buffer['prev'], buffer['w$'] + math.floor(vim.fn.winheight(0) / 2))
      buffer['diff'] = buffer['prev'] - cursor_now
      buffer['prev'] = buffer['prev']
        - (
          (buffer['diff'] > 0) and math.ceil(buffer['diff'] / 100 * config.speed)
          or math.floor(buffer['diff'] / 100 * config.speed)
        )
      buffer:push_front(buffer['prev'])
      -- Replace Signs
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
        callback.sc_timer:abort()
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
  sc_matrix = sc_matrix,
}
