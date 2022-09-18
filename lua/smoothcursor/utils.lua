local sc = {}
local smoothcursor_started = false

sc.smoothcursor_start = function()
    if smoothcursor_started then
        return
    end
    require("smoothcursor.callback").sc_callback()
    vim.api.nvim_create_augroup("SmoothCursor", { clear = true })
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        group = "SmoothCursor",
        callback = require("smoothcursor.callback").sc_callback
    })
    smoothcursor_started = true
end

sc.smoothcursor_stop = function()
    if not smoothcursor_started then
        return
    end
    vim.b.cursor_row_prev = nil
    require("smoothcursor.callback").unplace_signs()
    vim.api.nvim_del_augroup_by_name("SmoothCursor")
    smoothcursor_started = false
end

sc.smoothcursor_toggle = function()
    if smoothcursor_started then
        sc.smoothcursor_stop()
    else
        sc.smoothcursor_start()
    end
end

sc.smoothcursor_status = function()
    return smoothcursor_started
end

sc.smoothcursor_delete_signs = function()
    require("smoothcursor.callback").unplace_signs()
end

sc.with_smoothcursor = function(func, ...)
    vim.b.cursor_row_prev = vim.fn.getcurpos(vim.fn.win_getid())[2]
    require("smoothcursor.callback").reset_buffer(vim.b.cursor_row_prev)
    func(...)
    require("smoothcursor.callback").sc_callback()
end

sc.set_smoothcursor_highlight = function()
    if vim.api.nvim_get_namespaces().SmoothCursor == nil then
        vim.api.nvim_create_namespace('SmoothCursor')
        vim.api.nvim_create_namespace('SmoothCursorRed')
        vim.api.nvim_create_namespace('SmoothCursorOrange')
        vim.api.nvim_create_namespace('SmoothCursorYellow')
        vim.api.nvim_create_namespace('SmoothCursorGreen')
        vim.api.nvim_create_namespace('SmoothCursorAqua')
        vim.api.nvim_create_namespace('SmoothCursorBlue')
        vim.api.nvim_create_namespace('SmoothCursorPurple')
    end
    vim.api.nvim_set_hl(0, 'SmoothCursor', { bg = nil, fg = "#FFD400", default = true })
    vim.api.nvim_set_hl(0, 'SmoothCursorRed', { bg = nil, fg = '#FF0000', default = true })
    vim.api.nvim_set_hl(0, 'SmoothCursorOrange', { bg = nil, fg = '#FFA500', default = true })
    vim.api.nvim_set_hl(0, 'SmoothCursorYellow', { bg = nil, fg = '#FFFF00', default = true })
    vim.api.nvim_set_hl(0, 'SmoothCursorGreen', { bg = nil, fg = '#008000', default = true })
    vim.api.nvim_set_hl(0, 'SmoothCursorAqua', { bg = nil, fg = '#00FFFF', default = true })
    vim.api.nvim_set_hl(0, 'SmoothCursorBlue', { bg = nil, fg = '#0000FF', default = true })
    vim.api.nvim_set_hl(0, 'SmoothCursorPurple', { bg = nil, fg = '#800080', default = true })
end

return sc
