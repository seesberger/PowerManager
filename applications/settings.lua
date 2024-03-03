local GUI = require("GUI")

app = {
    --Global application config
    config = {
        position = {},
        size = {80, 30},
        backgroundColor = 0xFFFFFF,
        titleColor = 0x00FF00,
        title = "Settings",
        taskBarIcon = "S"
    },
    --function that is called when application is being started.
    initialize = function(application)
        local windowObject = createCustomWindow(
            application, 
            app.config.position[1],
            app.config.position[2],
            app.config.size[1],
            app.config.size[2]
        )
        windowObject.title.text = app.config.title
        windowObject.title.backgroundColor = app.config.backgroundColor
        windowObject.taskBarIcon.text = app.config.taskBarIcon
        local layout = windowObject:addChild(GUI.layout(1, 2, windowObject.width, windowObject.height, 1, 1))
        layout:addChild(GUI.text(1, 1, 0x000000, "Not implemented yet, but the Applications are working"))
        layout:addChild(GUI.text(1, 1, 0x000000, "This settings application is run from applications/settings.lua"))
        return windowObject
    end,
    --function that is called periodically for example to update some values. (FIXME: Not implemented yet)
    runTask = function()
    end
}
return app