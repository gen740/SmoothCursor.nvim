local config = require('smoothcursor.default')
local default_args = config.default_args

local function define_signs(args)
    if args.fancy.enable then
        if args.fancy.head ~= nil and args.fancy.head.cursor ~= nil then
            if args.fancy.head.linehl ~= nil then
                vim.cmd(string.format("sign define smoothcursor text=%s texthl=%s linehl=%s",
                    args.fancy.head.cursor,
                    args.fancy.head.texthl,
                    args.fancy.head.linehl
                ))
            else
                vim.cmd(string.format("sign define smoothcursor text=%s texthl=%s",
                    args.fancy.head.cursor,
                    args.fancy.head.texthl
                ))
            end
        end
        for idx, value in ipairs(args.fancy.body) do
            vim.cmd(string.format("sign define smoothcursor_%s text=%s texthl=%s",
                string.format("body%s", idx),
                value.cursor,
                value.texthl
            ))
        end
        if args.fancy.tail ~= nil and args.fancy.tail.cursor ~= nil then
            vim.cmd(string.format("sign define smoothcursor_tail text=%s texthl=%s",
                args.fancy.tail.cursor,
                args.fancy.tail.texthl
            ))
        end
    else
        if args.linehl ~= nil then
            vim.cmd(string.format("sign define smoothcursor text=%s texthl=%s linehl=%s",
                args.cursor,
                args.texthl,
                args.linehl
            ))
        else
            vim.cmd(string.format("sign define smoothcursor text=%s texthl=%s",
                args.cursor,
                args.texthl
            ))
        end
    end
end

local function setup(args)
    args = args == nil and {} or args
    for key, value in pairs(args) do
        if type(value) == "table" then
            for key2, value2 in pairs(value) do
                default_args[key][key2] = value2
            end
        else
            default_args[key] = value
        end
    end

    define_signs(default_args)

    if default_args.type == "exp" then
        config.callback = require('smoothcursor.callback').sc_callback_exp
    else
        config.callback = require('smoothcursor.callback').sc_callback_default
    end

    require("smoothcursor.callback").init()

    if default_args.type == "default" then
        require("smoothcursor.callback").sc_callback = require("smoothcursor.callback").sc_callback_default
    elseif default_args.type == "exp" then
        require("smoothcursor.callback").sc_callback = require("smoothcursor.callback").sc_callback_exp
    else
        vim.notify(string.format([=[[SmoothCursor.nvim] type %s does not exists, use "default"]=], default_args.type),
            vim.log.levels.WARN)
        require("smoothcursor.callback").sc_callback = require("smoothcursor.callback").sc_callback_default
    end

    if default_args.autostart then
        require('smoothcursor.utils').smoothcursor_start()
    end
end

return {
    setup = setup
}
