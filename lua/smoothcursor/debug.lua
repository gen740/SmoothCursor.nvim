local is_debug_mode = false
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
        vim.opt_local.signcolumn = "no"
        vim.opt_local.ft = "lua"
        vim.opt_local.buflisted = false
    end)
    vim.cmd([[wincmd p]])
    is_debug_mode = true
end

local function dump(o, level)
    local tab = '    '
    level = level or 0
    if type(o) == 'table' then
        local s = '{\n'
        for k, v in pairs(o) do
            s = s .. string.rep(tab, level + 1) .. tostring(k) .. ' = ' .. dump(v, level + 1) .. ',\n'
        end
        return s .. string.rep(tab, level) .. '}'
    else
        if type(o) == "string" then
            return string.format('"%s"', o)
        end
        return tostring(o)
    end
end

function sc.debug_callback(obj)
    if not is_debug_mode then
        return
    end
    vim.api.nvim_buf_set_lines(debug_bufid, 0, 1000, false, vim.split(dump(obj), "\n"))
end

return sc
