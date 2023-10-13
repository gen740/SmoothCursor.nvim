---@type integer | nil
local debug_bufid = nil

local sc = {}

function sc.debug()
  debug_bufid = vim.api.nvim_create_buf(false, true)
  vim.cmd([[vs]])
  vim.cmd([[vert res 50]])
  local debug_winid = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(debug_winid, debug_bufid)
  vim.api.nvim_buf_call(debug_bufid, function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
    vim.opt_local.ft = 'lua'
    vim.opt_local.buflisted = false
  end)
  vim.cmd([[wincmd p]])
end

local counter = 0
sc.reset_counter = 0
sc.buf_switch_counter = 0
sc.unplace_signs_conuter = 0

function sc.debug_callback(obj, extrainfo, extrafunc)
  if not debug_bufid then
    return
  end
  extrainfo = extrainfo or {}
  extrafunc = extrafunc or function() end
  counter = counter + 1
  vim.api.nvim_buf_set_lines(debug_bufid, 0, 1000, false, vim.split(vim.inspect(obj), '\n'))
  vim.api.nvim_buf_set_lines(debug_bufid, 0, 0, false, extrainfo)
  vim.api.nvim_buf_set_lines(
    debug_bufid,
    0,
    0,
    false,
    { string.format('Buffer Reset called %d Times', sc.reset_counter) }
  )
  vim.api.nvim_buf_set_lines(
    debug_bufid,
    0,
    0,
    false,
    { string.format('Buffer Switch called %d Times', sc.buf_switch_counter) }
  )
  vim.api.nvim_buf_set_lines(
    debug_bufid,
    0,
    0,
    false,
    { string.format('Unplace Signs Called %d Times', sc.unplace_signs_conuter) }
  )
  vim.api.nvim_buf_set_lines(
    debug_bufid,
    0,
    0,
    false,
    { string.format('Callback called %d Times', counter) }
  )
  extrafunc()
end

return sc
