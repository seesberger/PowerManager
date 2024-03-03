--Requirements must be met. all other things can be used from main application
local GUI = require("GUI")
local unicode = require("unicode")

app = {
    --Global application config
    --extend as you wish.
    config = {
        position = {},
        size = {120, 40},
        backgroundColor = 0xFFFFFF,
        titleColor = 0x00FF00,
        title = "CodeReader",
        taskBarIcon = "C",

        filesystemDescription = "View content of File",
        inputDefaultText = "",
        inputPlaceholder = "",
        inputBackgroundColor = 0xBBBBBB,
        inputBackgroundFocusedColor = 0xFFFFFF,
        inputTextColor = 0x000000,
        inputHeight = 35,
        inputWidht = 116,

        codeViewWidth = 116,
        codeViewHeight = 35
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

        layout:addChild(GUI.text(1, 1, app.config.inputTextColor, app.config.filesystemDescription))
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
            GUI.IO_MODE_BOTH, 
            GUI.IO_MODE_BOTH))
        filesystem.workPath = "/"
        filesystem:updateFileList()
        CodeView = {}
        function createCodeView(path)
            CodeView = layout:addChild(GUI.codeView(
                1, 1, 
                app.config.codeViewWidth, 
                app.config.codeViewHeight, 
                1, 1, 1, {}, {}, 
                GUI.LUA_SYNTAX_PATTERNS, 
                GUI.LUA_SYNTAX_COLOR_SCHEME, 
                true, {}))

            -- Open file and read it's lines
            local counter = 1
            for line in io.lines(path) do
                -- Replace tab symbols to 2 whitespaces and Windows line endings to UNIX line endings
                line = line:gsub("\t", "  "):gsub("\r\n", "\n")
                CodeView.maximumLineLength = math.max(CodeView.maximumLineLength, unicode.len(line))
                table.insert(CodeView.lines, line)

                counter = counter + 1
                if counter > CodeView.height then
                    --break
                end
            end
        end
        function updateLines()

        end
        filesystem.onItemSelected = function(path)
            filesystem:remove()
            createCodeView(path)
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