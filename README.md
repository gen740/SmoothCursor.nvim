# Smooth Cursor
![Image](https://user-images.githubusercontent.com/54583542/190096896-d9685802-71e4-41e9-927c-b6956f5a6bbd.gif)

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
    cursor = "", -- cursor shape
    intervals = 35, -- tick interval
    timeout = 3000,
    speed = 25, -- max is 100 to stick to your current position
    autostart = true,
    texthl = "SmoothCursor" -- highlight group, default is { bg = nil, fg = "#FFD400" }
}
```

## Command
| Command            | desctiption          |
| -------------      | -------------        |
| SmoothCursorStart  | start smooth cursor  |
| SmoothCursorStop   | stop smooth cursor   |
| SmoothCursorToggle | toggle smooth cursor |
