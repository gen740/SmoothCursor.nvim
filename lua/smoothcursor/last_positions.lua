local last_positions = {}

local callback = require('smoothcursor.callbacks')

---Format a buffer for saving it
---@param buffer number
---@return string
local function format_buf(buffer)
  return tostring(buffer)
end

---Set the last position of the cursor for a buffer
---@param buffer number
---@param mode string
---@param pos number[]
local function set_position(buffer, mode, pos)
  if last_positions[format_buf(buffer)] == nil then
    return
  end

  last_positions[format_buf(buffer)][mode] = pos
end

---Get the last positions for a buffer.
---Returns an empty table if the buffer is not found.
---@param buffer number
---@return LastPositionsInfo
local function get_positions(buffer)
  return last_positions[format_buf(buffer)] or {}
end

---Register a buffer to be tracked
---We explicitly register buffers to avoid tracking buffers that shouldn't save
---last positions (such as floating windows for example).
---@param buffer any
local function register_buffer(buffer)
  last_positions[format_buf(buffer)] = {}
end

local function unregister_buffer(buffer)
  last_positions[format_buf(buffer)] = nil
end

local function replace_signs()
  callback.unplace_signs(false, 'SmoothCursorLastPositions')
  for name, pos in pairs(get_positions(vim.api.nvim_get_current_buf())) do
    local line = pos[1]
    callback.place_sign(line, 'smoothcursor_' .. name, nil, 'SmoothCursorLastPositions')
  end
end

return {
  last_positions = last_positions,
  set_position = set_position,
  get_positions = get_positions,
  replace_signs = replace_signs,
  register_buffer = register_buffer,
  unregister_buffer = unregister_buffer,
}
