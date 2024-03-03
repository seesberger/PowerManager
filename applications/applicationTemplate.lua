--Requirements must be met. all other things can be used from main application
local GUI = require("GUI")

app = {
    --Global application config
    --extend as you wish.
    config = {
        --leave empty for dynamic initial position, fill out for absolute position
        position = {},
        size = {80, 30},
        backgroundColor = 0xFFFFFF,
        titleColor = 0x00FF00,
        title = "Application",
        taskBarIcon = "A"
    },

    --function that is called when application is being started.
    --needs parent application for eventHandler.
    initialize = function(application)
        --first, create a Window
        local windowObject = createCustomWindow(
            application, 
            app.config.position[1],
            app.config.position[2],
            app.config.size[1],
            app.config.size[2]
        )
        --then give it the correct title and task bar "symbol"
        windowObject.title.text = app.config.title
        windowObject.taskBarIcon.text = app.config.taskBarIcon
        --add a layout container to adaptively add content or remove it and let the content be hardcoded.
        local layout = windowObject:addChild(GUI.layout(1, 2, windowObject.width, windowObject.height, 1, 1))
        layout:addChild(GUI.text(1, 1, 0x000000, "Template Application"))
        layout:addChild(GUI.text(1, 1, 0x000000, "This is text"))
        layout:addChild(GUI.text(1, 1, 0xFF0000, "This is quite red text."))
        --return the object of the window content.
        return windowObject
    end,

    --function that is called periodically for example to update some values. (FIXME: Not implemented yet)
    runTask = function()
        --put it in
    end
}
return app