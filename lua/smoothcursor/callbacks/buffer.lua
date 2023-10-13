local sc_debug = require('smoothcursor.debug')

-- #require('smoothcursor.callbacks.buffer').buffer

local function create_buffer()
  return {
    buffer = {},
    length = 0,
    bufnr = 0, -- cache bufnr
    indexes = {},

    push_front = function(self, data)
      table.insert(self.indexes, 1, data)
      table.remove(self.indexes, #self.indexes)
    end,

    resize_buffer = function(self, size)
      local diff = size - #self.indexes
      if diff < 0 then
        for _ = 1, -diff, 1 do
          table.remove(self.indexes, #self.indexes)
        end
      else
        for _ = 1, diff, 1 do
          table.insert(self.indexes, 1, 0)
        end
      end
      self.length = #self.indexes
    end,

    switch_buf = function(self)
      self.bufnr = vim.fn.bufnr()
      sc_debug.buf_switch_counter = sc_debug.buf_switch_counter + 1
    end,

    all = function(self, value)
      for i = 1, #self.indexes, 1 do
        self.indexes[i] = value
      end
    end,

    is_stay_still = function(self)
      local first_val = self.indexes[1]
      for i = 2, #self.indexes do
        if first_val ~= self.indexes[i] then
          return false
        end
      end
      return true
    end,
  }
end

local function buffer_metatable()
  return {
    __index = function(t, k)
      if t.indexes[k] ~= nil then
        return t.indexes[k]
      end
      if t.buffer[t.bufnr] == nil then
        t.buffer[t.bufnr] = {}
      end
      return t.buffer[t.bufnr][k]
    end,
    __newindex = function(t, k, v)
      if t.indexes[k] ~= nil then
        t.indexes[k] = v
        return
      end
      if t.buffer[t.bufnr] == nil then
        t.buffer[t.bufnr] = {}
      end
      t.buffer[t.bufnr][k] = v
    end,
  }
end

return {
  buffer = setmetatable(create_buffer(), buffer_metatable()),
}
