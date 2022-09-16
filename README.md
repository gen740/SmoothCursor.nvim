# Smooth Cursor

https://user-images.githubusercontent.com/54583542/190581351-2e86f140-73a0-4523-80e1-f5c64d67be85.mp4

## What is this

It is easy to lose current cursor position, when using commands like `%` or `<c-f>`,`<c-b>`.
This plugin add sub-cursor to show scroll direction!!

## Install

- Require `neovim >= 0.7.0`
- Packer

```lua
use { 'gen740/SmoothCursor.nvim',
  config = function()
    require('smoothcursor').setup()
  end
}
```

## Config

```lua
default = {
    autostart = true,
    cursor = "",             -- cursor shape (need nerd font)
    intervals = 35,           -- tick interval
    linehl = nil,             -- highlight sub-cursor line like 'cursorline', "CursorLine" recommended
    type = "default",         -- define cursor movement calculate function, "default" or "exp" (exponential).
    fancy = {
        enable = false,       -- enable fancy mode
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
    priority = 10,            -- set marker priority
    speed = 25,               -- max is 100 to stick to your current position
    texthl = "SmoothCursor",  -- highlight group, default is { bg = nil, fg = "#FFD400" }
    threshold = 3,
    timeout = 3000,
}
```

### Fancy mode

https://user-images.githubusercontent.com/54583542/190581464-0b72c057-4644-406a-89e9-424e29d73257.mp4

## Commands

| Command             | desctiption               |
| ------------------- | ------------------------- |
| :SmoothCursorStart  | start smooth cursor       |
| :SmoothCursorStop   | stop smooth cursor        |
| :SmoothCursorStatus | show smooth cursor status |
| :SmoothCursorToggle | toggle smooth cursor      |
