local config = require('smoothcursor.config')

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
  uv.timer_start(self.timer, 0, config.config.intervals, vim.schedule_wrap(func))
  self.is_running = true
end

function sc_timer:abort()
  self.timer:stop()
  self.is_running = false
end

return {
  sc_timer = sc_timer,
}
