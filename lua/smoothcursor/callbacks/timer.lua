-- import 'config' module
local config = require('smoothcursor.config')

---@class ScTimer
---@field public is_running boolean
---@field public timer unknown
local ScTimer = {}
ScTimer.__index = ScTimer

--- Post if timer is stopped.
---@param func function
function ScTimer:post(func)
  if self.is_running then
    return
  end
  vim.uv.timer_start(self.timer, 0, config.value.intervals, vim.schedule_wrap(func))
  self.is_running = true
end

--- Abort the timer.
function ScTimer:abort()
  self.timer:stop()
  self.is_running = false
end

-- Initialize ScTimer object.
---@return ScTimer
local function newScTimer()
  local self = setmetatable({}, ScTimer)
  self.is_running = false
  self.timer = vim.uv.new_timer()
  return self
end

---@type ScTimer
return newScTimer()
