local sc = {}
local smoothcursor_started = false
local sc_callback = require("smoothcursor.callback").sc_callback

sc.smoothcursor_start = function()
    if smoothcursor_started then
        return
    end
    sc_callback()
    vim.api.nvim_create_augroup("SmoothCursor", { clear = true })
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        group = "SmoothCursor",
        callback = sc_callback

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
end

sc.smoothcursor_toggle = function()
    return smoothcursor_started and sc.smoothcursor_stop() or sc.smoothcursor_start()
end

sc.smoothcursor_status = function()
    return smoothcursor_started
end

sc.smoothcursor_delete_signs = function()
    require("smoothcursor.callback").unplace_signs()
end

return sc
