# Smooth Cursor
![Image](https://user-images.githubusercontent.com/54583542/190307057-780cda84-de7f-41e7-9cdf-9efe93f7f0c7.mov)

## What is this
It is easy to lose current cursor position, when using commands like `%` or `<c-f>`,`<c-b>`.
This plugin add sub-cursor to show scroll direction!!

## Installtion
- packer
```lua
use { 'gen740/SmoothCursor.nvim',
  config = function()
    require('smoothcursor').setup()
  end
}
```

## config
- default value
```lua
default = {
    autostart = true,
    cursor = "",             -- cursor shape
    intervals = 35,           -- tick interval
    linehl = nil,             -- highlight sub-cursor line like 'cursorline', "CursorLine" recommended
    type = "default"          -- "default" or "exp"
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

## Commands
| Command             | desctiption          |
| -------------       | -------------        |
| :SmoothCursorStart  | start smooth cursor  |
| :SmoothCursorStop   | stop smooth cursor   |
| :SmoothCursorToggle | toggle smooth cursor |
