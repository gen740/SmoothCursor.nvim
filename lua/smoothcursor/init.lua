local config = require('smoothcursor.config').value

---@class FancyBodyElement
---@field cursor string
---@field texthl string

---@class FancyHeadTailElement
---@field cursor string|nil
---@field texthl string|nil
---@field linehl string|nil

---@class FancyConfig
---@field enable boolean
---@field head FancyHeadTailElement
---@field body FancyBodyElement[]
---@field tail FancyHeadTailElement
---@field flyin_effect string|nil

---@class SmoothCursorConfig
---@field cursor string
---@field fancy FancyConfig
---@field cursorID integer
---@field intervals integer
---@field timeout integer
---@field type string
---@field threshold integer
---@field speed integer
---@field autostart boolean
---@field texthl string
---@field linehl string|nil
---@field priority integer
---@field disable_float_win boolean
---@field disabled_filetypes string[]|nil
---@field enabled_filetypes string[]|nil

---@param args SmoothCursorConfig
local function define_signs(args)
  if args.fancy.enable then
    if args.fancy.head ~= nil and args.fancy.head.cursor ~= nil then
      if args.fancy.head.linehl ~= nil then
        vim.fn.sign_define('smoothcursor', {
          text = args.fancy.head.cursor,
          texthl = args.fancy.head.texthl,
          linehl = args.fancy.head.linehl,
        })
      else
        vim.fn.sign_define('smoothcursor', {
          text = args.fancy.head.cursor,
          texthl = args.fancy.head.texthl,
        })
      end
    end
    for idx, value in ipairs(args.fancy.body) do
      vim.fn.sign_define(string.format('smoothcursor_body%s', idx), {
        text = value.cursor,
        texthl = value.texthl,
      })
    end
    if args.fancy.tail ~= nil and args.fancy.tail.cursor ~= nil then
      vim.fn.sign_define('smoothcursor_tail', {
        text = args.fancy.tail.cursor,
        texthl = args.fancy.tail.texthl,
      })
    end
  else
    if args.linehl ~= nil then
      vim.fn.sign_define('smoothcursor', {
        text = args.cursor,
        texthl = args.texthl,
        linehl = args.linehl,
      })
    else
      vim.fn.sign_define('smoothcursor', {
        text = args.cursor,
        texthl = args.texthl,
      })
    end
  end
end

local function init_and_start()
  define_signs(config)

  require('smoothcursor.callbacks').init()

  if config.type == 'default' then
    require('smoothcursor.callbacks').sc_callback =
      require('smoothcursor.callbacks.default').sc_default
  elseif config.type == 'exp' then
    require('smoothcursor.callbacks').sc_callback = require('smoothcursor.callbacks.exp').sc_exp
  elseif config.type == 'matrix' then
    require('smoothcursor.callbacks').sc_callback =
      require('smoothcursor.callbacks.matrix').sc_matrix
  else
    vim.notify(
      string.format(
        [=[[SmoothCursor.nvim] type %s does not exists, use "default", "exp" or "matrix"]=],
        config.type
      ),
      vim.log.levels.WARN
    )
    require('smoothcursor.callbacks').sc_callback =
      require('smoothcursor.callbacks.default').sc_default
  end

  local set_sc_hl = require('smoothcursor.utils').set_smoothcursor_highlight
  set_sc_hl()

  vim.api.nvim_create_augroup('SmoothCursorHightlight', { clear = true })
  vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
    group = 'SmoothCursorHightlight',
    callback = set_sc_hl,
  })

  if config.autostart then
    require('smoothcursor.utils').smoothcursor_start(false)
  end
end

---@param args SmoothCursorConfig
local function setup(args)
  args = args == nil and {} or args
  for key, value in pairs(args) do
    if key == 'fancy' then
      for key2, value2 in pairs(value) do
        config[key][key2] = value2
      end
    else
      config[key] = value
    end
  end
  init_and_start()
end

return {
  setup = setup,
  init_and_start = init_and_start,
  define_signs = define_signs,
}
