local config = require('smoothcursor.default')

local function setup(args)
    args = args == nil and {} or args
    for key, value in pairs(args) do
        config.default_args[key] = value
    end
    if config.default_args.linehl ~= nil then
        vim.cmd.sign(string.format("define smoothcursor text=%s texthl=%s linehl=%s",
            config.default_args.cursor,
            config.default_args.texthl,
            config.default_args.linehl
        ))
    else
        vim.cmd.sign(string.format("define smoothcursor text=%s texthl=%s",
            config.default_args.cursor,
            config.default_args.texthl
        ))
    end
    if config.default_args.autostart then
        require('smoothcursor.utils').smoothcursor_start()
    end
end

return {
    setup = setup
}
