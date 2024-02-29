--TODO: Implement
--this file is read by PowerManager. It provides information about installed applications for the desktopApplication.
--fill out template and insert if you want to implement this feature

Applications = {
    PowerManager = {
    name = "PowerManager",
    description = "It is me.",
    installDir = "/usr/PowerManager/",
    iconPath = "",
    shortcut = "powerman",
    dependencies = {
        "/lib/GUI.lua\n"..
        "/lib/images.lua\n"..
        "/lib/color.lua\n"..
        "/lib/advancedLua\n"..
        "/lib/doubleBuffering\n"..
        "/lib/FormatModules/OCIF.lua"
        }
    }

    
}

--[[
    template = {
        name = "",
        description = "",
        installPath = "",
        iconPath = "",
        shortcut = "",
        dependencies = {}
    }
]]