local GUI = require("GUI")

app = {
    --Global application config
    config = {
        position = {},
        size = {120, 35},
        backgroundColor = 0xFFFFFF,
        titleColor = 0x00FF00,
        title = "Settings",
        taskBarIcon = "S",

        settingsFilePath = "/usr/bin/PowerManager/settings.lua",
        settingsTable = {},
        submitButtonFunction = function() app.writeSettingsToFile(app.config.settingsTable) end
    },

    readSettingsFromFile = function()
        return dofile(app.config.settingsFilePath)
    end,

    -- Function to serialize a Lua table into a string
    serializeTable = function(table)
        local str = "{\n"
        for k, v in pairs(table) do
            str = str .. "" .. tostring(k) .. " = "
            if type(v) == "table" then
                str = str .. app.serializeTable(v)  -- Recursive call for nested tables
            elseif type(v) == "string" then
                str = str .. "\"" .. tostring(v) .. "\""
            else
                str = str .. tostring(v)
            end
            str = str .. ",\n"
        end
        str = str .. "}\n"
        return str
    end,


    writeSettingsToFile = function(table)
        local file = io.open(app.config.settingsFilePath, "w")
        if file then
            file:write("return " .. app.serializeTable(table))
            file:close()
        else
            print("Error: Unable to open settings file")
        end
    end,

    createSettingsTable = function(layout, settings, descriptions)
        descriptions = descriptions or {}
        for idx, v in ipairs(settings) do
            if type(v) == "table" then
                local col = layout:addColumn(GUI.SIZE_POLICY_RELATIVE, 1)
                col:addChild(GUI.text(1, 1, 0x000000, v.identifier))
                app.createSettingsTable(col, v.contents)
            else
                local button = layout:addChild(GUI.input(
                    1, 1, layout.width, 2, 
                    0xEEEEEE, 0x555555, 0x999999, 0xFFFFFF, 0x2D2D2D, 
                    v, descriptions[idx]))
                button.onInputFinished = function()
                    v = button.text
                end
            end
        end
    end,

    --function that is called when application is being started.
    initialize = function(application)
        --load Settings on startup
        app.config.settingsTable = app.readSettingsFromFile()
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
        app.createSettingsTable(layout, app.config.settingsTable)
        local submitButton = layout:addChild(GUI.button(
            1, 1, 
            app.config.size[1], 
            3, 
            0xFFFFFF, 0x555555, 0x880000, 0xFFFFFF, 
            "Submit values"))
        submitButton.animated = false
        submitButton.onTouch = app.config.submitButtonFunction
        return windowObject
    end,
    --function that is called periodically for example to update some values. (FIXME: Not implemented yet)
    runTask = function()
    end
}
return app