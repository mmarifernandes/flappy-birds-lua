function love.conf(t)
    t.version = "11.4"                  -- The LÖVE version this game was made for (string)

    t.window.title = "Flappy Birds"         -- The window title (string)
    -- t.window.icon = nil                 -- Filepath to an image to use as the window's icon (string)
    t.window.width = 800                -- The window width (number)
    t.window.height = 750               -- The window height (number)
    t.window.borderless = false         -- Remove all border visuals from the window (boolean)
    t.window.resizable = false          -- Let the window be user-resizable (boolean)

end