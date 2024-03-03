--settings application

Settings = {
    desktopApplication = {
        identifier = "desktopApplication",
        contents = {
            backgroundColor = 0x000000,
            titleBarColor = 0x0000BB,
            systemButtonColor = 0xBBBBBB,
            taskBarColor = 0xBBBBBB
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
        }
    }
]]