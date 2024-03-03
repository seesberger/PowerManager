--Requirements must be met. all other things can be used from main application
local GUI = require("GUI")

app = {
    --Global application config
    --extend as you wish.
    config = {
        position = {},
        size = {70, 40},
        backgroundColor = 0xFFFFFF,
        titleColor = 0x00FF00,
        title = "Launcher",
        taskBarIcon = "L",

        inputDescription = "Looking in /usr/PowerManager/applications",
        filesystemDescription = "Input filename and enter or click desired File in List",
        inputDefaultText = "",
        inputPlaceholder = "Filename.lua",
        inputBackgroundColor = 0xBBBBBB,
        inputBackgroundFocusedColor = 0xFFFFFF,
        inputTextColor = 0x000000,
        inputHeight = 35,
        inputWidht = 66
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
        --[[layout:addChild(GUI.text(1, 1, app.config.inputTextColor, app.config.inputDescription))
        local input = layout:addChild(GUI.input(
            1, 1, 
            app.config.inputWidht, 
            app.config.inputHeight,
            app.config.inputBackgroundColor, 
            app.config.inputTextColor, 
            app.config.inputTextColor, 
            app.config.inputBackgroundFocusedColor, 
            app.config.inputTextColor, 
            app.config.inputDefaultText, 
            app.config.inputPlaceholder))
        input.historyEnabled = true
        input.onInputFinished = function()
            LaunchApplication(application, "/usr/PowerManager/"..input.text)
        end]]

        layout:addChild(GUI.text(1, 1, app.config.inputTextColor, app.config.inputDescription))
        local filesystem = layout:addChild(GUI.filesystemTree(1, 1, 
            app.config.inputWidht, 
            app.config.inputHeight, 
            0xCCCCCC, 
            0x3C3C3C, 
            0x3C3C3C, 
            0x999999, 
            0x3C3C3C, 
            0xE1E1E1, 
            0xBBBBBB, 
            0xAAAAAA, 
            0xBBBBBB, 
            0x444444, 
            GUI.IO_MODE_FILE, 
            GUI.IO_MODE_FILE))
        filesystem.workPath = "/usr/PowerManager/applications/"
        filesystem:updateFileList()
        filesystem.onItemSelected = function(path)
            --GUI.alert(path)
            LaunchApplication(application, path)
        end
        --return the object of the window content.
        return windowObject
    end,

    --function that is called periodically for example to update some values. (FIXME: Not implemented yet)
    runTask = function()
        --put it in
    end
}
return app