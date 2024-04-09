local callback = require('smoothcursor.callbacks')
local buffer = callback.buffer

local config = require('smoothcursor.config')
local debug_callback = require('smoothcursor.debug').debug_callback

-- Default corsor callback. buffer["prev"] is always integer
local function sc_matrix()
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
    config.value.matrix.unstop
    or relative_diff > config.value.threshold
      and (config.value.max_threshold == nil or absolute_diff <= config.value.max_threshold)
  then
    local counter = 1
    callback.sc_timer:post(function()
      buffer['.'] = vim.fn.line('.')
      -- randomize_signs()
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
      callback.replace_signs_matrix()
      counter = counter + 1
      debug_callback(buffer, { 'Jump: True' })
      -- Timer management
      if config.value.matrix.unstop then
        return
      end

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
    if callback.matrix_head_exists() then
      local head_cursors = config.value.matrix.head.cursor
      local head_texthls = config.value.matrix.head.texthl
      if head_cursors and head_texthls then
        vim.fn.sign_define('smoothcursor_head', {
          text = head_cursors[math.random(1, #head_cursors)],
          text_hl = head_texthls[math.random(1, #head_texthls)],
        })
      end
      callback.place_sign(buffer['prev'], 'smoothcursor_head')
    end
    debug_callback(buffer, { 'Jump: False' })
  end
end

return {
  sc_matrix = sc_matrix,
}
