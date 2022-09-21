local config = require("smoothcursor.default")

-- Buffer specific list
--
BList = {}

function BList.new(length)
    local obj = {
        buffer = {},
        len = length,
        push_front =
        function(self, data)
            table.insert(self, 1, data)
            table.remove(self, self:length() + 1)
        end,
        length = function(self)
            return self.len
        end,
        is_stay_still = function(self)
            local first_val = self[1]
            for i = 2, self:length() do
                if first_val ~= self[i] then
                    return false
                end
            end
            return true
        end
    }
    return setmetatable(obj,
        {
            __index = function(t, k)
                local bufnr = vim.fn.bufnr()
                if t.buffer[bufnr] == nil then
                    local x = {}
                    for _ = 1, t.len do
                        table.insert(x, 1)
                    end
                    t.buffer[bufnr] = x
                end
                return t.buffer[bufnr][k]
            end,
            __newindex = function(t, k, v)
                local bufnr = vim.fn.bufnr()
                if t.buffer[bufnr] == nil then
                    local x = {}
                    for _ = 1, t.len do
                        table.insert(x, 1)
                    end
                    t.buffer[bufnr] = x
                end
                t.buffer[bufnr][k] = v
            end,
        })
end

local buffer = BList.new(1)

local function init()
    if config.default_args.fancy.enable then
        buffer = BList.new(#config.default_args.fancy.body + 1)
    end
end

local function reset_buffer(value)
    buffer["prev"] = value
    for _ = 1, buffer:length(), 1 do
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
    -- position = math.floor(position + 0.5)
    position = math.floor(position)
    if position < buffer['w0'] or position > buffer['w$'] then
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
    -- if it is not fancy mode Head is always set
    if not config.default_args.fancy.enable then
        return true
    end
    return config.default_args.fancy.head ~= nil and config.default_args.fancy.head.cursor ~= nil
end

-- Default corsor callback. buffer["prev"] is always integer
local function sc_default()
    buffer["now"] = vim.fn.getcurpos(vim.fn.win_getid())[2]
    if buffer["prev"] == nil then
        buffer["prev"] = buffer["now"]
    end
    buffer["diff"] = buffer["prev"] - buffer["now"]
    buffer["diff"] = math.min(buffer["diff"], vim.fn.winheight(0) * 2)
    buffer["w0"] = vim.fn.line("w0")
    buffer["w$"] = vim.fn.line("w$")
    if math.abs(buffer["diff"]) > config.default_args.threshold then
        local counter = 1
        sc_timer:post(
            function()
                buffer["now"] = vim.fn.getcurpos(vim.fn.win_getid())[2]
                if buffer["prev"] == nil then
                    buffer["prev"] = buffer["now"]
                end
                -- For <c-f>/<c-b> movement. buffer["prev"] has room for half screen.
                buffer["w0"] = vim.fn.line("w0")
                buffer["w$"] = vim.fn.line("w$")
                buffer["prev"] = math.max(buffer["prev"], buffer['w0'] - math.floor(vim.fn.winheight(0) / 2))
                buffer["prev"] = math.min(buffer["prev"], buffer['w$'] + math.floor(vim.fn.winheight(0) / 2))
                buffer["diff"] = buffer["prev"] - buffer["now"]
                buffer["prev"] = buffer["prev"]
                    - (
                    (buffer["diff"] > 0)
                        and math.ceil(buffer["diff"] / 100 * config.default_args.speed)
                        or math.floor(buffer["diff"] / 100 * config.default_args.speed)
                    )
                buffer:push_front(buffer["prev"])
                -- Replace sign
                unplace_signs()
                for i = buffer:length(), 2, -1 do
                    if not (
                        (math.max(buffer[i - 1], buffer[i]) < buffer['w0'] - 1) or
                            (math.min(buffer[i - 1], buffer[i]) > buffer['w$'] + 1)
                        ) then
                        for j = buffer[i - 1], buffer[i], ((buffer[i - 1] - buffer[i] < 0) and 1 or -1) do
                            place_sign(j, string.format("smoothcursor_body%d", i - 1))
                        end
                    end
                end
                if config.default_args.fancy.tail ~= nil and config.default_args.fancy.tail.cursor ~= nil then
                    place_sign(buffer[buffer:length()], "smoothcursor_tail")
                end
                if fancy_head_exists() then
                    place_sign(buffer[1], "smoothcursor")
                end
                counter = counter + 1
                -- Timer management
                if counter > (config.default_args.timeout / config.default_args.intervals) or
                    (buffer["diff"] == 0 and buffer[1] == buffer[buffer:length()]) then
                    if not fancy_head_exists() then
                        unplace_signs()
                    end
                    sc_timer:abort()
                end
            end)
    else
        buffer["prev"] = buffer["now"]
        buffer:push_front(buffer["prev"])
        unplace_signs()
        if fancy_head_exists() then
            place_sign(buffer["prev"], "smoothcursor")
        end
    end
end

-- Exponential corsor callback. buffer["prev"] is no longer integer.
local function sc_exp()
    buffer["now"] = vim.fn.getcurpos(vim.fn.win_getid())[2]
    if buffer["prev"] == nil then
        buffer["prev"] = buffer["now"]
    end
    buffer["diff"] = buffer["prev"] - buffer["now"]
    buffer["diff"] = math.min(buffer["diff"], vim.fn.winheight(0) * 2)
    buffer["w0"] = vim.fn.line("w0")
    buffer["w$"] = vim.fn.line("w$")
    if math.abs(buffer["diff"]) > config.default_args.threshold then
        local counter = 1
        sc_timer:post(
            function()
                buffer["now"] = vim.fn.getcurpos(vim.fn.win_getid())[2]
                if buffer["prev"] == nil then
                    buffer["prev"] = buffer["now"]
                end
                -- For <c-f>/<c-b> movement. buffer["prev"] has room for half screen.
                buffer["w0"] = vim.fn.line("w0")
                buffer["w$"] = vim.fn.line("w$")
                buffer["prev"] = math.max(buffer["prev"], buffer['w0'] - math.floor(vim.fn.winheight(0) / 2))
                buffer["prev"] = math.min(buffer["prev"], buffer['w$'] + math.floor(vim.fn.winheight(0) / 2))
                buffer["diff"] = buffer["prev"] - buffer["now"]
                buffer["prev"] = buffer["prev"] - buffer["diff"] / 100 * config.default_args.speed
                if math.abs(buffer["diff"]) < 0.5 then
                    buffer["prev"] = buffer["now"]
                end
                buffer:push_front(buffer["prev"])
                --- Replace Signs
                unplace_signs()
                for i = buffer:length(), 2, -1 do
                    if not (
                        (math.max(buffer[i - 1], buffer[i]) < buffer['w0'] - 1) or
                            (math.min(buffer[i - 1], buffer[i]) > buffer['w$'] + 1)
                        ) then
                        for j = buffer[i - 1], buffer[i], ((buffer[i - 1] - buffer[i] < 0) and 1 or -1) do
                            place_sign(j, string.format("smoothcursor_body%d", i - 1))
                        end
                    end
                end
                if config.default_args.fancy.tail ~= nil and config.default_args.fancy.tail.cursor ~= nil then
                    place_sign(buffer[buffer:length()], "smoothcursor_tail")
                end
                if fancy_head_exists() then
                    place_sign(buffer[1], "smoothcursor")
                end
                --- Timer management
                counter = counter + 1
                if counter > (config.default_args.timeout / config.default_args.intervals) or
                    (buffer["diff"] == 0 and buffer:is_stay_still()) then
                    if not fancy_head_exists() then
                        unplace_signs()
                    end
                    sc_timer:abort()
                end
            end)
    else
        buffer["prev"] = buffer["now"]
        buffer:push_front(buffer["prev"])
        unplace_signs()
        if fancy_head_exists() then
            place_sign(buffer["prev"], "smoothcursor")
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
