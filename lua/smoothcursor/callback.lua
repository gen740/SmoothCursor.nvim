local config = require("smoothcursor.default")

-- List For cursor position bufferStart ----------------------------------------
-- This List hold buffer local list of cursor position hiostory.
List = {}

---@param length number
List.new = function(length)
    vim.b.smooth_cursor_buffer = {}
    local obj = { buffer = vim.b.smooth_cursor_buffer }
    for _ = 1, length, 1 do
        table.insert(obj.buffer, 1, 0)
    end
    return setmetatable(obj.buffer, { __index = List })
end

function List:push_front(data)
    table.insert(self, 1, data)
    table.remove(self, #self)
end

function List:is_stay_still()
    local first_val = self[1]
    for _, value in ipairs(self) do
        if first_val ~= value then
            return false
        end
    end
    return true
end

local buffer = List.new(1)

local function init()
    if config.default_args.fancy.enable then
        buffer = List.new(#config.default_args.fancy.body + 1)
    end
end

local function reset_buffer(value)
    for _ = 1, #buffer, 1 do
        buffer:push_front(value)
    end
end

-- sc_timer --------------------------------------------------------------------
-- Hold unique uv timer.
local uv = vim.loop

local sc_timer = {
    is_running = false,
    timer = uv.new_timer()
}

-- post if timer is stop
---@param func function
function sc_timer:post(func)
    if self.is_runnig then
        return
    end
    uv.timer_start(self.timer, 0, config.default_args.intervals, vim.schedule_wrap(func))
    self.is_running = true
end

function sc_timer:abort()
    self.timer:stop()
    self.is_running = false
end

local function unplace_signs()
    vim.fn.sign_unplace('*', { buffer = vim.fn.bufname(), id = config.default_args.cursorID })
end

-- place 'name' sign to the 'position'
---@param position number
---@param name string
local function place_sign(position, name)
    -- TODO: I would also cache vim.fn.line outside this call
    if position < vim.fn.line('w0') or position > vim.fn.line('w$') then
        return
    end
    if name ~= nil then
        vim.fn.sign_place(
            config.default_args.cursorID,
            "SmoothCursor",
            name,
            vim.fn.bufname(),
            { lnum = position, priority = config.default_args.priority }
        )
    end
end

local function fancy_head_exists()
    return config.default_args.fancy.head ~= nil and config.default_args.fancy.head.cursor ~= nil
end

-- Default corsor callback. b:smoothcursor_row_prev is always integer
local function sc_default()
    -- 前のカーソルの位置が存在しないなら、現在の位置にする
    vim.b.smoothcurosr_row_now = vim.fn.getcurpos(vim.fn.win_getid())[2]
    if vim.b.smoothcursor_row_prev == nil then
        vim.b.smoothcursor_row_prev = vim.b.smoothcurosr_row_now
    end
    vim.b.smoothcursor_diff = vim.b.smoothcursor_row_prev - vim.b.smoothcurosr_row_now
    vim.b.smoothcursor_diff = math.min(vim.b.smoothcursor_diff, vim.fn.winheight(0))
    if math.abs(vim.b.smoothcursor_diff) > config.default_args.threshold then
        local counter = 1
        sc_timer:post(
            function()
                vim.b.smoothcurosr_row_now = vim.fn.getcurpos(vim.fn.win_getid())[2]
                if vim.b.smoothcursor_row_prev == nil then
                    vim.b.smoothcursor_row_prev = vim.b.smoothcurosr_row_now
                end
                vim.b.smoothcursor_row_prev = math.max(vim.b.smoothcursor_row_prev, vim.fn.line('w0'))
                vim.b.smoothcursor_row_prev = math.min(vim.b.smoothcursor_row_prev, vim.fn.line('w$'))
                vim.b.smoothcursor_diff = vim.b.smoothcursor_row_prev - vim.b.smoothcurosr_row_now
                vim.b.smoothcursor_row_prev = vim.b.smoothcursor_row_prev
                    - (
                    (vim.b.smoothcursor_diff > 0)
                        and math.ceil(vim.b.smoothcursor_diff / 100 * config.default_args.speed)
                        or math.floor(vim.b.smoothcursor_diff / 100 * config.default_args.speed)
                    )
                buffer:push_front(vim.b.smoothcursor_row_prev)
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
                    (vim.b.smoothcursor_diff == 0 and buffer[1] == buffer[#buffer]) then
                    if not fancy_head_exists() then
                        unplace_signs()
                    end
                    sc_timer:abort()
                end
            end)
    else
        vim.b.smoothcursor_row_prev = vim.b.smoothcurosr_row_now
        buffer:push_front(vim.b.smoothcursor_row_prev)
        unplace_signs()
        if fancy_head_exists() then
            place_sign(vim.b.smoothcursor_row_prev, "smoothcursor")
        end
    end
end

-- Exponential corsor callback. b:smoothcursor_row_prev is no longer integer.
local function sc_exp()
    -- If previous cursor position is not exists, use now position.
    vim.b.smoothcurosr_row_now = vim.fn.getcurpos(vim.fn.win_getid())[2]
    if vim.b.smoothcursor_row_prev == nil then
        vim.b.smoothcursor_row_prev = vim.b.smoothcurosr_row_now
    end
    vim.b.smoothcursor_diff = vim.b.smoothcursor_row_prev - vim.b.smoothcurosr_row_now
    vim.b.smoothcursor_diff = math.min(vim.b.smoothcursor_diff, vim.fn.winheight(0))
    if math.abs(vim.b.smoothcursor_diff) > config.default_args.threshold then
        local counter = 1
        sc_timer:post(
            function()
                vim.b.smoothcurosr_row_now = vim.fn.getcurpos(vim.fn.win_getid())[2]
                if vim.b.smoothcursor_row_prev == nil then
                    vim.b.smoothcursor_row_prev = vim.b.smoothcurosr_row_now
                end
                vim.b.smoothcursor_row_prev = math.max(vim.b.smoothcursor_row_prev, vim.fn.line('w0'))
                vim.b.smoothcursor_row_prev = math.min(vim.b.smoothcursor_row_prev, vim.fn.line('w$'))
                vim.b.smoothcursor_diff = vim.b.smoothcursor_row_prev - vim.b.smoothcurosr_row_now
                vim.b.smoothcursor_row_prev = vim.b.smoothcursor_row_prev
                    - vim.b.smoothcursor_diff / 100 * config.default_args.speed
                if math.abs(vim.b.smoothcursor_diff) < 0.5 then
                    vim.b.smoothcursor_row_prev = vim.b.smoothcurosr_row_now
                end
                buffer:push_front(vim.b.smoothcursor_row_prev)
                unplace_signs()
                for i = #buffer, 2, -1 do
                    for j = buffer[i - 1], buffer[i], ((buffer[i - 1] - buffer[i] < 0) and 1 or -1) do
                        place_sign(math.floor(j + 0.5), string.format("smoothcursor_body%d", i - 1))
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
                    (vim.b.smoothcursor_diff == 0 and buffer:is_stay_still()) then
                    if not fancy_head_exists() then
                        unplace_signs()
                    end
                    sc_timer:abort()
                end
            end)
    else
        vim.b.smoothcursor_row_prev = vim.b.smoothcurosr_row_now
        buffer:push_front(vim.b.smoothcursor_row_prev)
        unplace_signs()
        if fancy_head_exists() then
            place_sign(vim.b.smoothcursor_row_prev, "smoothcursor")
        end
    end
end

return {
    init = init,
    sc_callback_default = sc_default,
    sc_callback_exp = sc_exp,
    sc_callback = nil,
    unplace_signs = unplace_signs,
    reset_buffer = reset_buffer,
}
