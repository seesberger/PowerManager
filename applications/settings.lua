local GUI = require("GUI")

settings = {
    --Config for the window being created.
    windowConfig = {
        position = {},
        size = {},
        backgroundColor = 0xFFFFFF,
        titleColor = 0x00FF00,
        title = "Settings"
    },
    --function that is called when application is being started.
    initialize = function(application)
        local settingsWindow = createCustomWindow(
            application, 
            settings.windowConfig.position[1],
            settings.windowConfig.position[2],
            settings.windowConfig.size[1],
            settings.windowConfig.size[2])
        settingsWindow:addChild(GUI.layout())
    end,
    --function that is called periodically to e.g. update some values.
    run = function()
    end
}
return settings