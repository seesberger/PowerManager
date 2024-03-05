--Requirements must be met. all other things can be used from main application
local GUI = require("GUI")

app = {
    --Global application config
    --extend as you wish.
    config = {
        position = {},
        size = {80, 30},
        backgroundColor = 0xFFFFFF,
        titleColor = 0x00FF00,
        title = "Fick dich!",
        taskBarIcon = "F",
        runTaskDelay = 1
    },

    values = {

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
            app.config.size[2],
            nil,
            app.runTask,
            app.config.runTaskDelay,
            app.onClose
        )
        --then give it the correct title and task bar "symbol"
        windowObject.title.text = app.config.title
        windowObject.titleBar.color = app.config.titleColor
        windowObject.background.color = app.config.backgroundColor
        windowObject.taskBarIcon.text = app.config.taskBarIcon
        --add a layout container to adaptively add content or remove it and let the content be hardcoded.
        local layout = windowObject:addChild(GUI.layout(1, 1, windowObject.width, windowObject.height, 1, 1))

        --here comes the Fick Dich!
        app.values.progressbarWindow1 = layout:addChild(GUI.progressBar(1, 1, layout.width - 2, 0x3366CC, 0xEEEEEE, 0x000000, 50, true, true, "Fick-Dich-Meter: ", ""))
        local buttonProgressbarUp = layout:addChild(GUI.button(1, 1, layout.width, 3, 0xB4B4B4, 0xFFFFFF, 0x969696, 0xB4B4B4, "+++"))
        local buttonProgressbarDn = layout:addChild(GUI.button(1, 1, layout.width, 3, 0xB4B4B4, 0xFFFFFF, 0x969696, 0xB4B4B4, "---"))

        buttonProgressbarUp.onTouch = function()
            app.values.progressbarWindow1.value = app.values.progressbarWindow1.value + 5
        end
        buttonProgressbarDn.onTouch = function()
            app.values.progressbarWindow1.value = app.values.progressbarWindow1.value + 5
        end

        --return the Application window as object.
        return windowObject
    end,

    --function that is called periodically for example to update some values. (FIXME: Not implemented yet)
    runTask = function()
        if app.values.progressbarWindow1.value >= 100 then
            app.values.progressbarWindow1.value = 0
        end
        app.values.progressbarWindow1.value = app.values.progressbarWindow1.value + 2
    end
}
return app