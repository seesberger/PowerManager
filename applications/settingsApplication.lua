local GUI = require("GUI")

app = {
    --Global application config
    config = {
        position = {},
        size = {80, 30},
        backgroundColor = 0xFFFFFF,
        titleColor = 0x00FF00,
        title = "Settings",
        taskBarIcon = "S",

        settingsFilePath = "/usr/bin/PowerManager/settings.lua"
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


    writeSettingsToFile = function()
        local file = io.open(app.config.settingsFilePath, "w")
        if file then
            file:write("return " .. app.serializeTable(table)) -- Using the serpent library to serialize the table
            file:close()
        else
            print("Error: Unable to open settings file")
        end
    end,

    createSettingsInput = function(layout, settings)
        for k, v in ipairs(settings) do
            if type(v) == "table" then
                
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