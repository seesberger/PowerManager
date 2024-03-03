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
            Name = "powerman",
            Taregt = "/usr/bin/" -- target for file shortcut.lua
        },
        Files = {},

    }
}

Repository = {
        Owner = "seesberger",
        Name = "PowerManager",
        ShortName = "powerman",
        RepoIdentifier = "seesberger/PowerManager",
        Remote = SupportedRemotes.Github,
        CurrentBranch = "master",
-- implement: CurrentTag = "1.2.3-alpha"
}

Dependencies = {
    GutApi = {
        Type = "Script",
        -- fixme : instert repo here
    }
    -- GuiApi = {
    --     Type = "IntallFiles",
    --     Loose = false,
    --     Files = {
    --         {
    --             URL = "",
    --             Target = ""
    --         },
    --         {}
    --     }
    -- }
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