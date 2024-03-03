local args = {...}
local internet=require("internet")
local filesystem=require("filesystem")
local unicode=require("unicode")

YES = {"y","yes","Y","Yes","YES"}
NO = {"n","no","N","No","NO"}

SupportedRemotes = {
    Github = {
        Name = "GitHub",
        BaseUrl = "https://github.com/",
        RawApiUrl = "https://raw.githubusercontent.com/",
        Implemented = true
    },
    Gitea = {
        Name = "Gitea",
        BaseUrl = "https://git.realrobin.io",
        RawApiUrl = nil,
        Implemented = false
    }
}

--TODO: Make the config a file and read it on startup.
Defaults = {
    TemporaryDownloadPath = "/home/.tmp/git/",
    InstallationPath = "/usr/",
    LibraryPath = "/lib/",
    ManifestTarget = "/etc/manifest/", -- should maybe be "/home/.git-tool/"
    ShortcutTargetDir = "/usr/bin/",

    EmptyRepository = {
        Owner = nil, -- should be string
        Name = nil, -- should be string
        ShortName = nil, -- for example "powerman", used for shortcur naming. string
        RepoIdentifier = nil, -- should be string "owner/name"
        Remote = nil, -- SupportedRemoted.Github
        CurrentRef = nil, -- branch to pull from / current repo branch
        CurrentLocalPath = nil -- string to current repo location for operarions
    }
}



local function askYesOrNoQuestion(question, expectedTrue, expectedFalse, defaultYesOnEnter)
    local function checkContains(array,value)
        for idx, val in pairs(array) do
            if value == val then return true end
        end
        return false
    end

    if defaultYesOnEnter==true then print(question.." [Y/n]") else print(question.." [y/N]") end
    while true do
        local userInput = io.read("l")
        if checkContains({""}, userInput) then return defaultYesOnEnter end
        if checkContains(expectedTrue, userInput) then return true end
        if checkContains(expectedFalse, userInput) then return false end
        print("Please answer with yes or no. You can also press ENTER to choose the default option.")
    end
end

local function askTextQuestion(question, defaultAnswerOnEnter, allowOnly)
    local allowedInputsString = ""
    if allowOnly then for idx, entry in pairs(allowOnly) do allowedInputsString = allowedInputsString..entry end end
    if allowOnly then print(question.." ["..allowedInputsString.."]")
    else print(question) end
    local userInput = nil
    local found = false
    repeat
        userInput = io.read("l")
        if allowOnly then
            for idx, entry in pairs(allowOnly) do if entry == userInput then found = true end end
        else break end
    until found
    if userInput == "" then return defaultAnswerOnEnter else return userInput end
end

local function makeDirIfNotExists(target)
    print("--DEBUG 96: "..target)
    local succ, arg, err = pcall(filesystem.exists, target)
    if arg == nil then error(err) end
    if arg then
        print("--DEBUG 98: "..target)
        if not filesystem.isDirectory(target) then error("target directory already exists and is not a directory.") end
        if filesystem.get(target).isReadOnly() then error("target directory is read-only.") end
    else
        if not filesystem.makeDirectory(target) then error("directory creation failed") end
    end
end

--- todo: pcall and catch errors
local function downloadRepo(repository, autoOverride, targetDownloadPath)

    local function validateRepositoryIdentifier(repository)
        if not repository.RepoIdentifier:match("^[%w-.]*/[%w-.]*$") then
            print('"'..repository.RepoIdentifier..'" does not look like a valid repo identifier.\nShould be <owner>/<reponame>')
            return
        end
    end
    
    validateRepositoryIdentifier(repository)

    --- FIXME: If download only mode is enabled, set this to /home. still todo
    repository.CurrentLocalPath = targetDownloadPath.."/" --- set globally used path for current fs operations
    local success, res = pcall(makeDirIfNotExists, targetDownloadPath)
    if not success then error("the download failed because of filesystem errors.") end

    local function fetchFilesAndSubdirs(repository, remote, dir)
        dir = dir or "" -- default value, start at root dir
        if remote == SupportedRemotes.Github then
            print("fetching contents for "..repository.RepoIdentifier..dir)
            local githubApiUrl="https://api.github.com/repos/"..repository.RepoIdentifier.."/contents"..dir.."?ref="..repository.CurrentRef
            local success,chunks=pcall(internet.request,githubApiUrl)
            local raw=""
            local files={}
            local directories={}

            if success then for chunk in chunks do raw=raw..chunk end
            else error("you've been cut off. Serves you right.") end

            --- do not question the magic of the outer gods
            --- turns raw response into t, which has usable fields.
            raw=raw:gsub("%[","{"):gsub("%]","}"):gsub("(\".-\"):(.-[,{}])",function(a,b) return "["..a.."]="..b end)
            local t=load("return "..raw)()

            for i=1,#t do
                if t[i].type=="dir" then
                table.insert(directories,dir.."/"..t[i].name)

                local subfiles,subdirs=fetchFilesAndSubdirs(repository,remote,dir.."/"..t[i].name)
                for i=1,#subfiles do
                    table.insert(files,subfiles[i])
                end
                for i=1,#subdirs do
                    table.insert(directories,subdirs[i])
                end
                else
                files[#files+1]=dir.."/"..t[i].name
                end
            end

            return files, directories
        else error("not Implemented") end
    end

    --- fetch and make dirs in the target download path recursively
    local files,dirs=fetchFilesAndSubdirs(repository, repository.Remote, "")
    for i=1,#dirs do
        local success, err = pcall(makeDirIfNotExists, targetDownloadPath..dirs[i])
        if not success then error(("the download failed because of filesystem errors. %x"):format(err)) end
    end

    local replaceMode="ask"
    if autoOverride == true then replaceMode = "always" end

    local function downloadFiles(files, targetDownloadPath, replaceMode)
        local replace=nil
        local downloadedFileTargets = {}
        for i=1,#files do
            if replaceMode == "always" then replace = true end
            local fileExists = filesystem.exists(targetDownloadPath..files[i])
            if fileExists then
                --- FIXME dir löschen statt error
                if filesystem.isDirectory(targetDownloadPath..files[i]) then error("file "..targetDownloadPath..files[i].." blocked by directory with same name!") end
                
                if replace == nil then
                    local userInput = askTextQuestion("\nFile "..targetDownloadPath..files[i].." already exists.\nReplace with new version?","n",{"y","n","A","S"})

                    --- FIXME: replaceMode ist broken. A wird immer wieder gefragt.
                    if userInput=="A" then
                    replaceMode="always"
                    userInput="y"
                    elseif userInput=="S" then
                    replaceMode="never"
                    userInput="n"
                    end
                    if userInput == "y" then replace=true end
                    if userInput == "n" then replace=false end
                end
            end
            if fileExists and replace then filesystem.remove(targetDownloadPath..files[i]) end
            if replace or (replace == nil) then
                --- TODO @Freddy: Coole Animation hinzufügen
                print("downloading file "..files[i])
                --- HACK: RawApiUrl is for using Github Raw API. may have to be patched for Gitea Support
                local url=repository.Remote.RawApiUrl..repository.RepoIdentifier.."/"..repository.CurrentRef..files[i]
                local success,response=pcall(internet.request,url)
                if success then
                    local raw=""
                    for chunk in response do
                        raw=raw..chunk
                    end
                    local absoluteDownloadFileTargetPath = targetDownloadPath..files[i]
                    print("writing to "..absoluteDownloadFileTargetPath)
                    local file=io.open(absoluteDownloadFileTargetPath,"w")
                    if file then -- might be nil under wierd circumstances
                        file:write(raw)
                        file:close()
                    end
                    table.insert(downloadedFileTargets, files[i])
                else error("a file did not download correctly. aborting") end
            else error("file not removed, but installation was cancelled - This might result in a broken install.") end
        end
        --- return list of all abolute paths the files were downloaded to
        return downloadedFileTargets
    end

    success, res = pcall(downloadFiles, files, targetDownloadPath, replaceMode)
    if success then print("All files downloaded successfully.") return res else error(res) end
end

local function installFiles(config, downloadTargetDir)
    local installedFiles = {}
    local installTargetDir = config.Installation.TargetDirectory
    local filesToInstall = config.Installation.Files
    
    --- FIXME: ask user about replacing files.
    local replace = true
    makeDirIfNotExists(installTargetDir)

    for idx, file in pairs(filesToInstall) do
        local absoluteDownloadFilePath = downloadTargetDir.."/"..file
        print(idx..": Installing File "..absoluteDownloadFilePath.." to target directory "..installTargetDir..file)
        local fileExists = filesystem.exists(installTargetDir..file)
        if fileExists and replace then filesystem.remove(installTargetDir..file) end
        if replace or (replace == nil) then
            --- TODO @Freddy: Coole Animation hinzufügen
            os.execute("cp "..absoluteDownloadFilePath.." "..installTargetDir..file)
            table.insert(installedFiles, installTargetDir..file)
        else error("file not removed, but installation was cancelled - This might result in a broken install.") end
    end
    return installedFiles
end

local function installShortcut(currentRepoPath, sourceFile, shortcutName, targetDir)
    print("installing shortcut...")
    makeDirIfNotExists(targetDir)
    local currentTarget = currentRepoPath..sourceFile
    local shortcutInstallTarget = targetDir..shortcutName..".lua"
    os.execute("mv "..currentTarget.." "..shortcutInstallTarget)
    return {shortcutInstallTarget}
end

local function installDependencies(dependencies)
    print("Preparing dependency install...")

    local function installDependency(dependency)
        print("Installing "..dependency.Name)
        --Check for scripts contained in dependencies and execute it. Makes the thn a bit more versatile
        if dependency.Type == "Script" then
            -- FIXME how to get correct args for script? or disallow args
            --            dependency.InstallScript(repository.CurrentLocalPath, Defaults.LibraryPath)
            print("Dependency with type Script skipped, not Implemented")
        elseif dependency.Type == "InstallFiles" then
            local targets = ""
            for idx, file in pairs(dependency.Files) do
                if file.MakeDir then makeDirIfNotExists(file.MakeDir) end
                os.execute("wget -f "..file.URL.." "..file.Target)
                targets = targets..file.Target.."\n"
            end
            return targets
        elseif dependency.Type == "Repository" then
            print("Dependency with type Repository skipped, not Implemented")
            --- TODO: Recursive run git-tool
        end
    end

    local installedDependencies = {}
    for idx, dep in pairs(dependencies) do
        print(idx..": Installing dependency "..dep.Name)
        local installedDependency = installDependency(dep)
        table.insert(installedDependencies,installedDependency)
    end
    return installedDependencies
end

local function removeDownloads(downloadTargetDir, downloadedFiles)
    for idx, file in pairs(downloadedFiles) do
        file = file:sub(2,-1) --- get "file" from previous string "/file"
        local absFilePath = downloadTargetDir.."/"..file
        print(idx..": Removing temporary file "..absFilePath)
        local fileExists = filesystem.exists(absFilePath)
        if fileExists then filesystem.remove(absFilePath) end
    end
    print("cleaned temporary files.")
end

local function removeFilesViaManifest(manifestTarget)
    local success = true
    local removedFiles = {}

    print("reading manifest file...")
    local manifestFile = io.open(manifestTarget, "rb")
    if not manifestFile then return error("manifest file: file io error") end
    --- remove every file in the manifest
    for file in io.lines(manifestTarget) do
        print("Trying to remove file "..file)
        local fileExists = filesystem.exists(file)
        if fileExists then
            filesystem.remove(file)
            print("removed file "..file)
            table.insert(removedFiles, file)
        else
            print("could not locate file "..file)
            success = false
        end
    end
    manifestFile:close()
    local fileExists = filesystem.exists(manifestTarget)
    if fileExists then filesystem.remove(manifestTarget) end
    return success, removedFiles
end

local function createManifest(installedDependencies, installedFiles, installedShortcuts, manifestTarget, repoName)
    makeDirIfNotExists(manifestTarget)
    local manifest = ""
    for idx, file in pairs(installedFiles) do
        manifest = manifest..file.."\n"
    end
    for idy, shortcut in pairs(installedShortcuts) do
        manifest = manifest..shortcut.."\n"
    end
    for idz, dependency in pairs(installedDependencies) do
        manifest = manifest..dependency.."\n"
    end
    print("writing manifest to "..manifestTarget..repoName)
    local file=io.open(manifestTarget..repoName,"w")
    if file then -- might be nil under wierd circumstances
        file:write(manifest)
        file:close()
    end
end

local function readInstallConfig(configfile)
    local config, repo, deps = dofile(configfile)
    return config, repo, deps
end

local function printHelpText()
    local helpText =        "This updater pulls the git files for installation and application updates.\n"..
    "Usage:\n" ..
    "updater <option>  - no args: default bootstrap install of powerman\n"..
    "  '' -h         - this help text\n"..
    "  '' -x         - install custom repository (experimental)\n"..
    "  '' -u         - uninstall via manifest"
    print(helpText)
end

local function run(cliArgs)

    local function bootstrapPowerman()
        
    end

    local function setupExperimentalCustomInstall()
        if askYesOrNoQuestion("Are you sure about using experimental custom install?", YES, NO, false) then
            print("Asking some questions about repo to set up:")

            local repo = Defaults.EmptyRepository

            local remoteAnswer = askTextQuestion("Github (default on ENTER) or Gitea?", "Github", {"Github", "Gitea"})
            if remoteAnswer == "Github" or remoteAnswer == "" then repo.Remote = SupportedRemotes.Github
            elseif remoteAnswer == "Gitea" then repo.Remote = SupportedRemotes.Gitea
            end
            --- owner and name -> repoIdentifier?
            repo.Owner = askTextQuestion("Owner of Repo? (DEFAULT: seesberger)", "seesberger")
            repo.Name = askTextQuestion("Name of Repo? (DEFAULT: PowerManager)", "PowerManager")
            repo.RepoIdentifier = askTextQuestion("Use "..repo.Owner.."/"..repo.Name.."? (ENTER) or type custom repo id: ", repo.Owner.."/"..repo.Name)
            repo.CurrentRef = askTextQuestion("please specify ref to download (default master): ", "master")
            repo.CurrentLocalPath = ""

            --- 1. download the actual repo. This will update repo to reflect config in the installconfig, like the shortcut name
            print("downloading "..repo.RepoIdentifier.." from "..repo.Remote.Name)
            local downloadTargetDir = Defaults.TemporaryDownloadPath..repo.RepoIdentifier
            local downloadedFiles = downloadRepo(repo,false,downloadTargetDir)
            local updatedPath = repo.CurrentLocalPath
            local configfile = repo.CurrentLocalPath.."installconfig.lua"
            local config, repoUpdated, deps = readInstallConfig(configfile)
            repo = repoUpdated
            repo.CurrentLocalPath = updatedPath

            --- 2. find dependencies - if they exist, download and install them
            local installedDependencies = installDependencies(deps)
            --- 3. install the actual program

            local installedFiles = installFiles(config, downloadTargetDir)
            local installedShortcuts = installShortcut(repo.CurrentLocalPath, config.Installation.Shortcut.Source, config.Installation.Shortcut.Name, config.Installation.Shortcut.Target)

            --- remove temporary files and create manifest for later uninstall
            removeDownloads(downloadTargetDir, downloadedFiles)
            createManifest(installedDependencies, installedFiles, installedShortcuts, Defaults.ManifestTarget, repo.Name)
        end
    end

    local function uninstallViaManifest()
        print("DANGER: A malformed manifest file can trigger unwanted removal of files! Be careful and only use if you know what you are doing.")
        local manifestTarget = "/etc/manifest/"..askTextQuestion("Which manifest file do you want to use? (ENTER with empty input to abort, looking in /etc/manifest)", nil, nil)
        if manifestTarget then removeFilesViaManifest(manifestTarget) else print("Aborted. No harm was done.") end
    end

    if #cliArgs<1 then
        print("No Arguments given. For help, please check -h or --help")
        return
    end
    if cliArgs[1] == "-h" then
        printHelpText()
        return
    elseif cliArgs[1] == "-x" then
        setupExperimentalCustomInstall()
        return
    elseif cliArgs[1] == "-u" then
        uninstallViaManifest()
        return
    else
        print('"'..cliArgs[1]..'" - Bad argument. Try --help')
    print("Program exiting....")
    end
end

run(args)
