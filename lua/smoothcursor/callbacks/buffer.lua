local sc_debug = require('smoothcursor.debug')

return {
  buffer = (function()
    local obj = {
      buffer = {},
      length = 1,
      bufnr = 1, -- chach bufnr
      push_front = function(self, data)
        table.insert(self, 1, data)
        table.remove(self, self.length + 1)
      end,
      resize_buffer = function(self, size)
        if self.length == size then
          return
        end
        local diff = size - self.length
        if diff < 0 then
          for _ = 1, -diff, 1 do
            table.remove(self, self.length + 1)
          end
        else
          for _ = 1, diff, 1 do
            table.insert(self, 1, 0)
          end
        end
        self.length = size
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
  end)(),
}
