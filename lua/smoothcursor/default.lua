return {
    default_args = {
        cursor = "",
        fancy = {
            enable = false,
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
        cursorID = 23874823,
        intervals = 35,
        timeout = 3000,
        type = "default",
        threshold = 3,
        speed = 25,
        autostart = true,
        texthl = "SmoothCursor",
        linehl = nil,
        priority = 10,
    }
}
