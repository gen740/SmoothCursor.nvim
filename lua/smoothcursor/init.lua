local config = require('smoothcursor.config')

---@class MatrixHeadElement
---@field cursor string[]|function|nil
---@field texthl string[]|function
---@field linehl string|function|nil

---@class MatrixBodyElement
---@field length integer
---@field cursor string[]|function
---@field texthl string[]|function

---@class MatrixTailElement
---@field cursor string[]|function|nil
---@field texthl string[]|function

---@class MatrixConfig
---@field head MatrixHeadElement
---@field body MatrixBodyElement
---@field tail MatrixTailElement
---@field unstop boolean

---@class FancyHeadElement
---@field cursor string|nil
---@field texthl string|nil
---@field linehl string|nil

---@class FancyBodyElement
---@field cursor string
---@field texthl string

---@class FancyTailElement
---@field cursor string|nil
---@field texthl string|nil

---@class FancyConfig
---@field enable boolean
---@field head FancyHeadElement
---@field body FancyBodyElement[]
---@field tail FancyTailElement

---@class SmoothCursorConfig
---@field cursor string
---@field texthl string
---@field linehl string|nil
---@field always_redraw boolean
---@field flyin_effect string|nil
---@field fancy FancyConfig
---@field matrix MatrixConfig
---@field cursorID integer
---@field intervals integer
---@field timeout integer
---@field type string
---@field threshold integer
---@field speed integer
---@field autostart boolean
---@field priority integer
---@field disable_float_win boolean
---@field disabled_filetypes string[]|nil
---@field enabled_filetypes string[]|nil
---@field show_last_positions string|nil -- "enter" | "leave"

-- Used for debugging, doesn't contain all the actual fields.
-- More meant to be used as an example.
---@class LastPositionsInfo
---@field i number[]
---@field n number[]
---@field V number[]
---@field v number[]

-- local function define_signs(name, cursor, texthl,  )

---@param args SmoothCursorConfig
local function smoothcursor_define_signs(args)
  -- dummy cursor to always on the current cursor, prevent the cursor
  -- from disappearing
  vim.fn.sign_define('smoothcursor_dummy', {
    text = ' ',
    texthl = 'Normal',
  })

  if args.type == 'matrix' then
    -- Do not define signs on matrix mode
    -- define signs when place
    return
  elseif args.fancy.enable then
    -- Fancy Mode
    if args.fancy.head and args.fancy.head.cursor then
      if args.fancy.head.linehl then
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
    if args.fancy.body then
      for idx, value in ipairs(args.fancy.body) do
        vim.fn.sign_define(string.format('smoothcursor_body%s', idx), {
          text = value.cursor,
          texthl = value.texthl,
        })
      end
    end
    if args.fancy.tail and args.fancy.tail.cursor then
      vim.fn.sign_define('smoothcursor_tail', {
        text = args.fancy.tail.cursor,
        texthl = args.fancy.tail.texthl,
      })
    end
  else
    -- Normal mode
    if args.linehl then
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
  smoothcursor_define_signs(config.value)

  require('smoothcursor.callbacks').init()

  if config.value.type == 'default' then
    require('smoothcursor.callbacks').sc_callback =
      require('smoothcursor.callbacks.default').sc_default
  elseif config.value.type == 'exp' then
    require('smoothcursor.callbacks').sc_callback = require('smoothcursor.callbacks.exp').sc_exp
  elseif config.value.type == 'matrix' then
    require('smoothcursor.callbacks').sc_callback =
      require('smoothcursor.callbacks.matrix').sc_matrix
  else
    vim.notify(
      string.format(
        [=[[SmoothCursor.nvim] type %s does not exists, use "default", "exp" or "matrix"]=],
        config.value.type
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

  if config.value.autostart then
    require('smoothcursor.utils').smoothcursor_start(false)
  end
end

---@param args SmoothCursorConfig
local function setup(args)
  args = args == nil and {} or args
  config.value = vim.tbl_deep_extend('force', config.value, args)
  init_and_start()
end

return {
  setup = setup,
  init_and_start = init_and_start,
  get_last_positions = function()
    return require'smoothcursor.callbacks.default'.last_positions
  end,
}
