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
        taskBarIcon = "A",
        runTaskDelay = 5
    },

    --function that is called when application is being started.
    --needs parent application for eventHandler.
    initialize = function(application)
        --first, create a Window and give it the config.
        local windowObject = createCustomWindow(
            application, 
            app.config.position[1],
            app.config.position[2],
            app.config.size[1],
            app.config.size[2],
            nil,
            app.runTask,
            app.config.runTaskDelay,
            app.onClose
        )

        --then give it the correct title and stuff
        windowObject.title.text = app.config.title
        windowObject.titleBar.color = app.config.titleColor
        windowObject.background.color = app.config.backgroundColor
        windowObject.taskBarIcon.text = app.config.taskBarIcon
        --add a layout container to adaptively add content or remove it and let the content be hardcoded.
        local layout = windowObject:addChild(GUI.layout(1, 2, windowObject.width, windowObject.height, 1, 1))
        layout:addChild(GUI.text(1, 1, 0x000000, "Template Application"))
        layout:addChild(GUI.text(1, 1, 0x000000, "This is text"))
        layout:addChild(GUI.text(1, 1, 0xFF0000, "This is quite red text."))
        --return the object of the window content.
        return windowObject
    end,

    --function that is called each frame to update stuff. --FIXME: Maybe dont run every frame...
    runTask = function(application)
        --GUI.alert("Frame animation alert")
    end,

    --Stop services or save some settings. Is called on deletion of the application window.
    onClose = function(application)
        --what should be done?
    end
}
return app