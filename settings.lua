--settings application

Settings = {
    desktopApplication = {
        identifier = "Desktop colors",
        contents = {
            backgroundColor = 0x000000,
            titleBarColor = 0x0000BB,
            systemButtonColor = 0xBBBBBB,
            taskBarColor = 0xBBBBBB
        },
        contentDescriptions = {
            backgroundColorText = "Background",
            titleBarColorText = "Title bars",
            systemButtonColorText = "System Buttons",
            taskBarColorText = "Taskbar",
        }
    },
    settingsApplication = {
        identifier = "Settings App",
        contents = {
            
        },
        contentDescriptions = {

        }
    }
}

return Settings

--[[template to insert here:
    table.insert(Settings, <config table>)

    <config table>:
    template = {
        identifier = "template",
        contents = {
            backgroundColor = 0xBBBBBB,
        },
        contentDescriptions = {
            backgroundColorText = "Background Color",
        }
    }
]]