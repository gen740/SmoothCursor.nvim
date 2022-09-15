local config = require("smoothcursor.default")

local function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

local uv = vim.loop
local cursor_timer = uv.new_timer()

local function smoothcursor()
    -- 前のカーソルの位置が存在しないなら、現在の位置にする
    if vim.b.cursor_row_prev == nil then
        vim.b.cursor_row_prev = vim.fn.getcurpos(vim.fn.win_getid())[2]
    end
    vim.b.cursor_row_now = vim.fn.getcurpos(vim.fn.win_getid())[2]
    vim.b.diff = vim.b.cursor_row_prev - vim.b.cursor_row_now
    if math.abs(vim.b.diff) > 3 then -- たくさんジャンプしたら
        -- 動いているタイマーがあればストップする
        cursor_timer:stop()
        local counter = 1
        -- タイマーをスタートする
        uv.timer_start(cursor_timer, 0, config.default_args.intervals, vim.schedule_wrap(
            function()
                vim.b.cursor_row_now = vim.fn.getcurpos(vim.fn.win_getid())[2]
                vim.b.diff = vim.b.cursor_row_prev - vim.b.cursor_row_now
                vim.b.cursor_row_prev = vim.b.cursor_row_prev
                    - (
                    (vim.b.diff > 0)
                        and math.ceil(vim.b.diff / 100 * config.default_args.speed)
                        or math.floor(vim.b.diff / 100 * config.default_args.speed)
                    )
                vim.cmd(string.format("silent! sign unplace %d file=%s",
                    config.default_args.cursorID,
                    vim.fn.expand("%:p")))
                vim.cmd(string.format("silent! sign place %d line=%d name=smoothcursor priority=%d file=%s",
                    config.default_args.cursorID,
                    vim.b.cursor_row_prev,
                    config.default_args.priority,
                    vim.fn.expand("%:p")))
                counter = counter + 1
                if counter > (config.default_args.timeout / config.default_args.intervals) or vim.b.diff == 0 then
                    cursor_timer:stop()
                end
            end)
        )
    else
        vim.b.cursor_row_prev = vim.b.cursor_row_now
        vim.cmd(string.format("silent! sign unplace %d file=%s", config.default_args.cursorID, vim.fn.expand("%:p")))
        vim.cmd(string.format("silent! sign place %d line=%d name=smoothcursor priority=%d file=%s",
            config.default_args.cursorID,
            vim.b.cursor_row_now,
            config.default_args.priority,
            vim.fn.expand("%:p")))
    end
end

local function test()
    print(dump(config.default_args))
end

return {
    smoothcursor_callback = smoothcursor,
    debug_func = test
}
