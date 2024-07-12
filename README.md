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

```lua
{ 'gen740/SmoothCursor.nvim',
  config = function()
    require('smoothcursor').setup()
  end
}
```

## Config

- default value
```lua
require('smoothcursor').setup({
    type = "default",           -- Cursor movement calculation method, choose "default", "exp" (exponential) or "matrix".

    cursor = "",              -- Cursor shape (requires Nerd Font). Disabled in fancy mode.
    texthl = "SmoothCursor",   -- Highlight group. Default is { bg = nil, fg = "#FFD400" }. Disabled in fancy mode.
    linehl = nil,              -- Highlights the line under the cursor, similar to 'cursorline'. "CursorLine" is recommended. Disabled in fancy mode.

    fancy = {
        enable = false,        -- enable fancy mode
        head = { cursor = "▷", texthl = "SmoothCursor", linehl = nil }, -- false to disable fancy head
        body = {
            { cursor = "󰝥", texthl = "SmoothCursorRed" },
            { cursor = "󰝥", texthl = "SmoothCursorOrange" },
            { cursor = "●", texthl = "SmoothCursorYellow" },
            { cursor = "●", texthl = "SmoothCursorGreen" },
            { cursor = "•", texthl = "SmoothCursorAqua" },
            { cursor = ".", texthl = "SmoothCursorBlue" },
            { cursor = ".", texthl = "SmoothCursorPurple" },
        },
        tail = { cursor = nil, texthl = "SmoothCursor" } -- false to disable fancy tail
    },

    matrix = {  -- Loaded when 'type' is set to "matrix"
        head = {
            -- Picks a random character from this list for the cursor text
            cursor = require('smoothcursor.matrix_chars'),
            -- Picks a random highlight from this list for the cursor text
            texthl = {
                'SmoothCursor',
            },
            linehl = nil,  -- No line highlight for the head
        },
        body = {
            length = 6,  -- Specifies the length of the cursor body
            -- Picks a random character from this list for the cursor body text
            cursor = require('smoothcursor.matrix_chars'),
            -- Picks a random highlight from this list for each segment of the cursor body
            texthl = {
                'SmoothCursorGreen',
            },
        },
        tail = {
            -- Picks a random character from this list for the cursor tail (if any)
            cursor = nil,
            -- Picks a random highlight from this list for the cursor tail
            texthl = {
                'SmoothCursor',
            },
        },
        unstop = false,  -- Determines if the cursor should stop or not (false means it will stop)
    },

    autostart = true,           -- Automatically start SmoothCursor
    always_redraw = true,       -- Redraw the screen on each update
    flyin_effect = nil,         -- Choose "bottom" or "top" for flying effect
    speed = 25,                 -- Max speed is 100 to stick with your current position
    intervals = 35,             -- Update intervals in milliseconds
    priority = 10,              -- Set marker priority
    timeout = 3000,             -- Timeout for animations in milliseconds
    threshold = 3,              -- Animate only if cursor moves more than this many lines
    max_threshold = nil,        -- If you move more than this many lines, don't animate (if `nil`, deactivate check)
    disable_float_win = false,  -- Disable in floating windows
    enabled_filetypes = nil,    -- Enable only for specific file types, e.g., { "lua", "vim" }
    disabled_filetypes = nil,   -- Disable for these file types, ignored if enabled_filetypes is set. e.g., { "TelescopePrompt", "NvimTree" }
    -- Show the position of the latest input mode positions. 
    -- A value of "enter" means the position will be updated when entering the mode.
    -- A value of "leave" means the position will be updated when leaving the mode.
    -- `nil` = disabled
    show_last_positions = nil,  
})
```

### Fancy mode

https://user-images.githubusercontent.com/54583542/190581464-0b72c057-4644-406a-89e9-424e29d73257.mp4

### Matrix mode

https://github.com/gen740/SmoothCursor.nvim/assets/54583542/ba3f90b1-e9ff-4729-b094-7eae7d2b1deb

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
| :SmoothCursorJump <mode>       | Jump to the given <mode>'s last position         |

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


### How do I add icons (signs) for mode's last positions?

You can decide which modes should be added. 
Define the `smoothcursor_<mode>` sign group and set your icon.
Each `<mode>` is a lowercase letter, e.g., `n` for normal mode, `i` for insert mode, etc.

**example**
```lua
vim.fn.sign_define('smoothcursor_v', { text = ' ' })
vim.fn.sign_define('smoothcursor_V', { text = '' })
vim.fn.sign_define('smoothcursor_i', { text = '' })
vim.fn.sign_define('smoothcursor_�', { text = '' })
vim.fn.sign_define('smoothcursor_R', { text = '󰊄' })
```

