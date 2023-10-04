# Smooth Cursor

https://user-images.githubusercontent.com/54583542/190581351-2e86f140-73a0-4523-80e1-f5c64d67be85.mp4

## What is this

It is easy to lose current cursor position, when using commands like `%` or `<c-f>`,`<c-b>`.
This plugin add sub-cursor to show scroll direction!!

## Install

- Require `neovim >= 0.7.0`
- [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use { 'gen740/SmoothCursor.nvim',
  config = function()
    require('smoothcursor').setup()
  end
}
```
- [lazy.nvim](https://github.com/folke/lazy.nvim)

## Config

- default value
```lua
require('smoothcursor').setup({
    autostart = true,
    cursor = "",              -- cursor shape (need nerd font)
    texthl = "SmoothCursor",   -- highlight group, default is { bg = nil, fg = "#FFD400" }
    linehl = nil,              -- highlight sub-cursor line like 'cursorline', "CursorLine" recommended
    type = "default",          -- define cursor movement calculate function, "default" or "exp" (exponential).
    fancy = {
        enable = false,        -- enable fancy mode
        head = { cursor = "▷", texthl = "SmoothCursor", linehl = nil },
        body = {
            { cursor = "", texthl = "SmoothCursorRed" },
            { cursor = "", texthl = "SmoothCursorOrange" },
            { cursor = "●", texthl = "SmoothCursorYellow" },
            { cursor = "●", texthl = "SmoothCursorGreen" },
            { cursor = "•", texthl = "SmoothCursorAqua" },
            { cursor = ".", texthl = "SmoothCursorBlue" },
            { cursor = ".", texthl = "SmoothCursorPurple" },
        },
        tail = { cursor = nil, texthl = "SmoothCursor" }
    },
    flyin_effect = nil,        -- "bottom" or "top"
    speed = 25,                -- max is 100 to stick to your current position
    intervals = 35,            -- tick interval
    priority = 10,             -- set marker priority
    timeout = 3000,            -- timout for animation
    threshold = 3,             -- animate if threshold lines jump
    disable_float_win = false, -- disable on float window
    enabled_filetypes = nil,   -- example: { "lua", "vim" }
    disabled_filetypes = nil,  -- this option will be skipped if enabled_filetypes is set. example: { "TelescopePrompt", "NvimTree" }
})
```

### Fancy mode

https://user-images.githubusercontent.com/54583542/190581464-0b72c057-4644-406a-89e9-424e29d73257.mp4

## Commands

| Command                        | Description                                      |
| ------------------------------ | ------------------------------------------------ |
| :SmoothCursorStart             | Start smooth cursor                              |
| :SmoothCursorStop              | Stop smooth cursor                               |
| :SmoothCursorStop --keep-signs | Stop smooth cursor without deleting signs        |
| :SmoothCursorStatus            | Show smooth cursor status                        |
| :SmoothCursorToggle            | Toggle smooth cursor                             |
| :SmoothCursorFancyToggle       | Toggle fancy mode                                |
| :SmoothCursorFancyOn           | Turn on fancy mode                               |
| :SmoothCursorFancyOff          | Turn off fancy mode                              |
| :SmoothCursorDeleteSigns       | Delete all signs if exist                        |

## FAQs

### How do I change the sub-cursor highlight to match the current mode?

You can use autocmd to Change highlight

**example**
```lua
local autocmd = vim.api.nvim_create_autocmd

autocmd({ 'ModeChanged' }, {
  callback = function()
    local current_mode = vim.fn.mode()
    if current_mode == 'n' then
      vim.api.nvim_set_hl(0, 'SmoothCursor', { fg = '#8aa872' })
      vim.fn.sign_define('smoothcursor', { text = '' })
    elseif current_mode == 'v' then
      vim.api.nvim_set_hl(0, 'SmoothCursor', { fg = '#bf616a' })
      vim.fn.sign_define('smoothcursor', { text = '' })
    elseif current_mode == 'V' then
      vim.api.nvim_set_hl(0, 'SmoothCursor', { fg = '#bf616a' })
      vim.fn.sign_define('smoothcursor', { text = '' })
    elseif current_mode == '' then
      vim.api.nvim_set_hl(0, 'SmoothCursor', { fg = '#bf616a' })
      vim.fn.sign_define('smoothcursor', { text = '' })
    elseif current_mode == 'i' then
      vim.api.nvim_set_hl(0, 'SmoothCursor', { fg = '#668aab' })
      vim.fn.sign_define('smoothcursor', { text = '' })
    end
  end,
})
```

https://user-images.githubusercontent.com/54583542/220056425-a7698013-7173-4247-9d40-d468b24df47a.mov

