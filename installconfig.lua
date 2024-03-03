--This file is used by git-tool.
--require = ("installconfig")
--If a a Table is given the Name "Script" it will automatically run the contained Function "InstallScript" while installing dependencies

Config = {
--    TemporaryDownloadPath = "/home/.tmp/git/",
--    InstallationPath = "/usr/",
--    LibraryPath = "/lib/",
--    ManifestTarget = "/etc/manifest/", -- should maybe be "/home/.git-tool/"
--    ShortcutTargetDir = "/usr/bin/",
--    RunOnBoot = false
    Installation = {
        Shortcut = {
            Source = "shortcut.lua",
            Name = "powerman",
            Target = "/usr/bin/" -- target for file shortcut.lua
        },
        TargetDirectory = {
            Main = "/usr/bin/PowerManager",
            Subdirs = {"/usr/bin/PowerManager/applications"}
        },
        Files = {
            "desktopApplication.lua",
            "git-tool.lua",
            "main.lua",
            "settings.lua",
            "PowerManagerLegacy.lua",
            "applications/applications.lua",
            "applications/applicationTemplate.lua",
            "applications/energyCellReadout.lua",
            "applications/fickDichMeter.lua",
            "applications/settings.lua"
        }
    }
}

Repository = {
        Owner = "seesberger",
        Name = "PowerManager",
        ShortName = "powerman",
        RepoIdentifier = "seesberger/PowerManager",
        Remote = SupportedRemotes.Github,
        CurrentRef = "master",
-- implement: CurrentTag = "1.2.3-alpha"
}

Dependencies = {
    -- GutApi = {
    --     Type = "Repository",
    --     -- fixme : instert repo here
    --     Name  = "GUI API",
    --     Repository = {
    --         Owner = "seesberger",
    --         Name = "OpenComputers-GUI",
    --         ShortName = "ocgui",
    --         RepoIdentifier = "seesberger/OpenComputers-GUI",
    --         Remote = SupportedRemotes.Github,
    --         CurrentRef = "master"
    --     }
    -- }
    GuiApi = {
        Name = "GUI Libraries",
        Type = "InstallFiles",
        Loose = false, -- not implemented
        Files = {
            {
                URL = "https://raw.githubusercontent.com/seesberger/OpenComputers-GUI/master/doubleBuffering.lua",
                Target = "/lib/doubleBuffering.lua"
            },
            {
                URL = "https://raw.githubusercontent.com/seesberger/OpenComputers-GUI/master/image.lua",
                Target = "/lib/image.lua"
            },{
                URL = "https://raw.githubusercontent.com/seesberger/OpenComputers-GUI/master/color.lua",
                Target = "/lib/color.lua"
            },{
                URL = "https://raw.githubusercontent.com/seesberger/OpenComputers-GUI/master/advancedLua.lua",
                Target = "/lib/advancedLua.lua"
            },
            {
                URL = "https://raw.githubusercontent.com/seesberger/OpenComputers-GUI/master/GUI.lua",
                Target = "/lib/GUI.lua"
            },
            {
                URL = "https://raw.githubusercontent.com/seesberger/OpenComputers-GUI/master/FormatModules/OCIF.lua",
                Target = "/lib/FormatModules/OCIF.lua",
                MakeDir = "/lib/FormatModules/"
            }
        }
    }
}

return Config, Repository, Dependencies

--[[
    Template:
    dep1 = {
        Name = "",
        Url = "",
        InstallTarget = ""
    },
    dependencyInstall = {
        Name = "Script",
        InstallScript = function(temporaryPath, targetPath)
            os.execute("")
        end
    }
]]