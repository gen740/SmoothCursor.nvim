local config = require("smoothcursor.default")

local uv = vim.loop
local cursor_timer = uv.new_timer()

List = {}

---@param length number
List.new = function(length)
    local obj = { buffer = {} }
    for _ = 1, length, 1 do
        table.insert(obj.buffer, 1, 0)
    end
    return setmetatable(obj.buffer, { __index = List })
end

function List:push_front(data)
    table.insert(self, 1, data)
    table.remove(self, #self)
end

local buffer = List.new(1)

local function init()
    if config.default_args.fancy.enable then
        buffer = List.new(#config.default_args.fancy.body + 1)
    end
end

local function unplace_signs()
    local file = vim.fn.expand("%:p")
    vim.cmd(string.format("silent! sign unplace %d group=* file=%s",
        config.default_args.cursorID,
        file))
end

local function normalize_buffer(value)
    for _ = 1, #buffer, 1 do
        buffer:push_front(value)
    end
end

---@param position number
---@param name string
local function place_sign(position, name)
    local file = vim.fn.expand("%:p")
    if name ~= nil then
        vim.cmd(string.format("silent! sign place %d line=%d name=%s group=%s priority=%d file=%s",
            config.default_args.cursorID,
            position,
            name,
            "SmoothCursor",
            config.default_args.priority,
            file))
    end
end

local function fancy_head_exists()
    return config.default_args.fancy.head ~= nil and config.default_args.fancy.head.cursor ~= nil
end

local function sc_default()
    -- 前のカーソルの位置が存在しないなら、現在の位置にする
    if vim.b.cursor_row_prev == nil then
        vim.b.cursor_row_prev = vim.fn.getcurpos(vim.fn.win_getid())[2]
    end
    vim.b.cursor_row_now = vim.fn.getcurpos(vim.fn.win_getid())[2]
    vim.b.diff = vim.b.cursor_row_prev - vim.b.cursor_row_now
    if math.abs(vim.b.diff) > config.default_args.threshold then -- たくさんジャンプしたら
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
                buffer:push_front(vim.b.cursor_row_prev)
                unplace_signs()
                for i = #buffer, 2, -1 do
                    for j = buffer[i - 1], buffer[i], ((buffer[i - 1] - buffer[i] < 0) and 1 or -1) do
                        place_sign(j, string.format("smoothcursor_body%d", i - 1))
                    end
                end
                if config.default_args.fancy.tail ~= nil and config.default_args.fancy.tail.cursor ~= nil then
                    place_sign(buffer[#buffer], "smoothcursor_tail")
                end
                if fancy_head_exists() then
                    place_sign(buffer[1], "smoothcursor")
                end
                counter = counter + 1
                if counter > (config.default_args.timeout / config.default_args.intervals) or
                    (vim.b.diff == 0 and buffer[1] == buffer[#buffer]) then
                    if not fancy_head_exists() then
                        unplace_signs()
                    end
                    cursor_timer:stop()
                end
            end)
        )
    else
        vim.b.cursor_row_prev = vim.b.cursor_row_now
        buffer:push_front(vim.b.cursor_row_prev)
        unplace_signs()
        place_sign(vim.b.cursor_row_prev, "smoothcursor")
    end
end

local function sc_exp()
    -- 前のカーソルの位置が存在しないなら、現在の位置にする
    if vim.b.cursor_row_prev == nil then
        vim.b.cursor_row_prev = vim.fn.getcurpos(vim.fn.win_getid())[2]
    end
    vim.b.cursor_row_now = vim.fn.getcurpos(vim.fn.win_getid())[2]
    vim.b.diff = vim.b.cursor_row_prev - vim.b.cursor_row_now
    if math.abs(vim.b.diff) > config.default_args.threshold then -- たくさんジャンプしたら
        -- 動いているタイマーがあればストップする
        cursor_timer:stop()
        local counter = 1
        -- タイマーをスタートする
        uv.timer_start(cursor_timer, 0, config.default_args.intervals, vim.schedule_wrap(
            function()
                vim.b.cursor_row_now = vim.fn.getcurpos(vim.fn.win_getid())[2]
                vim.b.diff = vim.b.cursor_row_prev - vim.b.cursor_row_now
                vim.b.cursor_row_prev = vim.b.cursor_row_prev
                    - vim.b.diff / 100 * config.default_args.speed
                if math.abs(vim.b.diff) < 0.5 then
                    vim.b.cursor_row_prev = vim.b.cursor_row_now
                end
                buffer:push_front(vim.b.cursor_row_prev)
                unplace_signs()
                for i = #buffer, 2, -1 do
                    for j = buffer[i - 1], buffer[i], ((buffer[i - 1] - buffer[i] < 0) and 1 or -1) do
                        place_sign(j, string.format("smoothcursor_body%d", i - 1))
                    end
                end
                if config.default_args.fancy.tail ~= nil and config.default_args.fancy.tail.cursor ~= nil then
                    place_sign(buffer[#buffer], "smoothcursor_tail")
                end
                if fancy_head_exists() then
                    place_sign(buffer[1], "smoothcursor")
                end
                counter = counter + 1
                if counter > (config.default_args.timeout / config.default_args.intervals) or
                    (vim.b.diff == 0 and buffer[1] == buffer[#buffer]) then
                    if not fancy_head_exists() then
                        unplace_signs()
                    end
                    cursor_timer:stop()
                end
            end)
        )
    else
        vim.b.cursor_row_prev = vim.b.cursor_row_now
        buffer:push_front(vim.b.cursor_row_prev)
        unplace_signs()
        place_sign(vim.b.cursor_row_prev, "smoothcursor")
    end
end

return {
    init = init,
    sc_callback_default = sc_default,
    sc_callback_exp = sc_exp,
    sc_callback = nil,
    unplace_signs = unplace_signs,
    normalize_buffer = normalize_buffer,
}
