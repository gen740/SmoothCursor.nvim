local config = require('smoothcursor.default')

local function setup(args)
    args = args == nil and {} or args
    for key, value in pairs(args) do
        config.default_args[key] = value
    end
end

return {
    setup = setup
}
