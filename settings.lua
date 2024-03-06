--settings application

Settings = {
    desktopApplication = {
        identifier = "Desktop colors",
        contents = {
            backgroundColor = {
                value = 0x000000,
                identifier = "Background"},
            titleBarColor = {
                value = 0x0000BB,
                identifier = "Title bars"},
            systemButtonColor = {
                value = 0xBBBBBB,
                identifier = "System buttons"},
            taskBarColor = {
                value = 0xBBBBBB,
                identifier = "Taskbar"},
        }
    },
    settingsApplication = {
        identifier = "Settings App",
        contents = {
            backgroundColor = {
                value = 0x000000,
                identifier = "Background"},
            titleBarColor = {
                value = 0x0000BB,
                identifier = "Title bar"},
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