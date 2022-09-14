local config = require('smoothcursor.default')

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

local function setup(args)
    args = args == nil and {} or args
    for key, value in pairs(args) do
        config.default_args[key] = value
    end
    print(dump(config.default_args))
    vim.cmd.sign(string.format("define smoothcursor text=%s", config.default_args.cursor))
end

return {
    setup = setup
}
