local config = require('smoothcursor.default')
local default_args = config.default_args

local function define_signs(args)
    if args.fancy.enable then
        if args.fancy.head ~= nil and args.fancy.head.cursor ~= nil then
            if args.fancy.head.linehl ~= nil then
                vim.fn.sign_define("smoothcursor", {
                    text = args.fancy.head.cursor,
                    texthl = args.fancy.head.texthl,
                    linehl = args.fancy.head.linehl
                })
            else
                vim.fn.sign_define("smoothcursor", {
                    text = args.fancy.head.cursor,
                    texthl = args.fancy.head.texthl
                })
            end
        end
        for idx, value in ipairs(args.fancy.body) do
            vim.fn.sign_define(string.format("smoothcursor_body%s", idx), {
                text = value.cursor,
                texthl = value.texthl
            })
        end
        if args.fancy.tail ~= nil and args.fancy.tail.cursor ~= nil then
            vim.fn.sign_define("smoothcursor_tail", {
                text = args.fancy.tail.cursor,
                texthl = args.fancy.tail.texthl
            })
        end
    else
        if args.linehl ~= nil then
            vim.fn.sign_define("smoothcursor", {
                text = args.cursor,
                texthl = args.texthl,
                linehl = args.linehl
            })
        else
            vim.fn.sign_define("smoothcursor", {
                text = args.cursor,
                texthl = args.texthl
            })
        end
    end
end

local function setup(args)
    args = args == nil and {} or args
    for key, value in pairs(args) do
        if key == "fancy" then
            for key2, value2 in pairs(value) do
                default_args[key][key2] = value2
            end
        else
            default_args[key] = value
        end
    end


    define_signs(default_args)

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

    local set_sc_hl = require("smoothcursor.utils").set_smoothcursor_highlight
    set_sc_hl()

    vim.api.nvim_create_augroup('SmoothCursorHightlight', { clear = true })
    vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        group = 'SmoothCursorHightlight',
        callback = set_sc_hl
    })

    if default_args.autostart then
        require('smoothcursor.utils').smoothcursor_start()
    end
end

return {
    setup = setup
}
