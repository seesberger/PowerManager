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

EmptyRepository = {
    Owner = nil,
    Name = nil,
    ShortName = nil,
    RepoIdentifier = nil,
    Remote = nil,
    CurrentBranch = nil,
    CurrentLocalPath = nil
}

---default repo to update
DefaultRepository = {
    Owner = "seesberger",
    Name = "PowerManager",
    ShortName = "powerman",
    RepoIdentifier = "seesberger/PowerManager",
    Remote = SupportedRemotes.Github,
    CurrentBranch = "master",
    CurrentLocalPath = ""
}

DefaultTemporaryDownloadPath = "/home/.tmp/git/"
DefaultInstallationPath = "/usr/"

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
    if filesystem.exists(target) then
        if not filesystem.isDirectory(target) then error("target directory already exists and is not a directory.") end
        if filesystem.get(target).isReadOnly() then error("target directory is read-only.") end
    else
        if not filesystem.makeDirectory(target) then error("directory creation failed") end
    end
end

--- todo: pcall and catch errors
local function downloadRepo(repository, remote, autoOverride, targetDownloadPath)

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
            local githubApiUrl="https://api.github.com/repos/"..repository.RepoIdentifier.."/contents"..dir
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
                local url=repository.Remote.RawApiUrl..repository.RepoIdentifier.."/"..repository.CurrentBranch..files[i]
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

local function installFiles(downloadedFiles, downloadTargetDir, installTargetDir)
    local installedFiles = {}
    
    --- FIXME: ask user about replacing files.
    local replace = true
    makeDirIfNotExists(installTargetDir)
    for idx, file in pairs(downloadedFiles) do
        local absoluteDownloadFilePath = downloadTargetDir.."/"..file:sub(2,-1)
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

local function installShortcut(currentRepoPath, shortcutName, targetDir)
    print("installing shortcut...")
    makeDirIfNotExists(targetDir)
    local currentTarget = currentRepoPath.."shortcut.lua"
    local shortcutInstallTarget = targetDir..shortcutName..".lua"
    os.execute("mv "..currentTarget.." "..shortcutInstallTarget)
    return {shortcutInstallTarget}
end

--- todo: automatic read of dependency list (txt file containing lines with <link> <dst> or somethink like it)
--- removeme
local function legacyInstallDependencies()
    print("Legacy Mode: Installing hardcoded dependencies...")
    os.execute("wget -f https://github.com/kevinkk525/OC-GUI-API/raw/master/shapes_default.lua /lib/shapes_default.lua")
    os.execute("wget -f https://github.com/kevinkk525/OC-GUI-API/raw/master/GUI.lua /lib/GUI.lua")
    os.execute("wget -f https://github.com/kevinkk525/OC-GUI-API/raw/master/term_mod.lua /lib/term_mod.lua")
    os.execute("wget -f https://github.com/kevinkk525/OC-GUI-API/raw/master/tech_demo.lua /home/GUI_tech_demo.lua")
    local installedDependencies = {"/lib/shapes_default.lua", "/lib/GUI.lua", "/lib/term_mod.lua", "/home/GUI_tech_demo.lua"}
    return installedDependencies
end

local function installDependencies(repository)
    print("Getting information about dependencies of installation candidate")
    ---reads the dependency file to create a list of dependencies: {{"url1","installpath1"},{"url2","installpath2"}} 
    local function createDependencyList(currentRepoPath)
        --- assume repository is well-formed. try catch maybe later on
        --- FIXME: Add capability of dependency.lua file containing a table describing deps which is then dynamically loaded on runtime
        local function readDependencyFile(filePath, commentChar)
            local file = io.open(filePath, "rb")
            if not file then error("file io error") end

            local dependencyNames = {}
            local dependencies = {}
            local lastName = nil

            for line in io.lines(filePath) do
                print("DEBUG: line="..line)
                if line:sub(1,1) == commentChar then
                    local dependencyName = line:sub(3,-1) --expects "# name"
                    lastName = dependencyName
                    table.insert(dependencyNames, dependencyName)
                    print("DEBUG: dependencyName="..dependencyName)
                    goto continue_lines_loop
                else -- expects "url target"
                    local cnt = 0
                    local dependency = {
                        Name=lastName,
                        Url=nil,
                        InstallTarget=nil
                    }
                    for word in line:gmatch("%S+") do
                        if cnt==0 then dependency.Url=word
                            cnt = cnt+1
                        elseif cnt==1 then dependency.InstallTarget=word end
                    end
                    table.insert(dependencies, dependency)
                    print("DEBUG: words=")
                    
                end
                ::continue_lines_loop::
            end
            file:close()
            
            return dependencyNames, dependencies;
        end

        local dependencyNames, dependencies = readDependencyFile(currentRepoPath.."dependencies", "#")

        --- names might later get version information
        local function sanityCheck(names, dependencies)
            -- local countDepNames = 0
            -- local countDepWords = 0
            -- local totalWCount = 0
            -- for idx, name in pairs(names) do
            --     print("DEBUG: idx="..idx.." name="..name.." count="..countDepNames.." luaCount="..countDepNames+1)
            --     countDepNames = countDepNames+1
            -- end
            -- for idx, dep in pairs(dependencies) do
            --     print("DEBUG: idx="..idx.." count="..countDepWords.." luaCount="..countDepWords+1)
            --     countDepWords = countDepWords+1
            -- end
            -- print("DEBUG: cDWords="..countDepWords.." totalWC="..totalWCount.." cDNames="..countDepNames)
            -- if totalWCount / 2 == countDepWords then
            --     print("found "..countDepNames.." dependencies with "..countDepWords.." individual files to install.")
            --     return true
            -- else return false end
            return true
            --- FIXME historisch gewachsen
        end
        --local sanityCheckPassed = sanityCheck(dependencyNames, dependencyWordList)
        --if not sanityCheckPassed then error("Dependency File seems broken. No dependenciess will be installed, this might result in a broken install.") end

        for idx, dep in pairs(dependencies) do
            print("DEBUG: .."..idx..": dependency={Name="..dep.Name..", Url="..dep.Url..", InstallTarget="..dep.InstallTarget.."}")
        end
        return dependencies
    end

    local dependencyList = createDependencyList(repository.CurrentLocalPath)
    print("Created dependency list.")

    local function installDependency(dependency)
        os.execute("wget -f "..dependency.Url.." "..dependency.InstallTarget)
        return dependency.InstallTarget
    end

    local installedDependencies = {}
    for idx, dep in pairs(dependencyList) do
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

local function printHelpText()
    local helpText =        "This updater pulls the git files for installation and application updates.\n"..
    "Usage:\n" ..
    "updater <option>  - no args: manual update and install\n"..
    "  '' -h         - this help text\n"..
    "  '' -d         - LEGACY: install default config (will be removed in subsequent releases)\n"..
    "  '' -x         - install custom repository (experimental)\n"..
    "  '' -u         - uninstall via manifest"
    print(helpText)
end

local function run(cliArgs)
    local repo = EmptyRepository

    local function setupDefaultInstall()
        --- fix legacy shit
        local function runFullInstallTask(repository, shortcutName)
            --- first, download the actual repo.
            --- then, find dependencies - if then exist, download and install them
            --- then, install the actual program
            local installTargetDir  = "/usr/"..repository.Name
            local shortcutTargetDir = "/usr/bin/"
            local downloadTargetDir = DefaultTemporaryDownloadPath..repository.RepoIdentifier
            local manifestTarget = "/etc/manifest/"

            local installedDependencies = legacyInstallDependencies() --only for testing while new version not implemented yet
            print("downloading "..repository.RepoIdentifier)
            local downloadedFiles = downloadRepo(repository, repository.Remote, false, downloadTargetDir) --enable auto-overwrite in other situations still todo
            local installedFiles = installFiles(downloadedFiles, downloadTargetDir, installTargetDir)
            local installedShortcuts = installShortcut(repository.CurrentLocalPath, shortcutName, shortcutTargetDir)

            --- remove temporary files and create manifest for later uninstall
            removeDownloads(downloadTargetDir, downloadedFiles)
            createManifest(installedDependencies, installedFiles, installedShortcuts, manifestTarget, repository.Name)
        end
        --- ask user about repo
        if askYesOrNoQuestion("Use default config? (github::seesberger/PowerManager)?",YES,NO,true) == true then
            repo = DefaultRepository
            --- ask user about shortcutname
            if askYesOrNoQuestion("Use default shortcut name \"powerman\"?",YES,NO,true) then shortcutName = "powerman" end
            runFullInstallTask(repo, shortcutName)
        else print("other things not implemented yet") end
    end

    local function setupExperimentalCustomInstall()
        if askYesOrNoQuestion("Are you sure about using experimental custom install?", YES, NO, false) then
            print("Asking some questions about repo to set up:")
            --- remote setup
            --- FIXME: default on ENTER is broken
            local remoteAnswer = askTextQuestion("Github (default on ENTER) or Gitea?", "Github", {"Github", "Gitea"})
            if remoteAnswer == "Github" or remoteAnswer == "" then repo.Remote = SupportedRemotes.Github
            elseif remoteAnswer == "Gitea" then repo.Remote = SupportedRemotes.Gitea
            end
            --- owner and name -> repoIdentifier?
            repo.Owner = askTextQuestion("Owner of Repo? (DEFAULT: TheRealRobin)", "TheRealRobin")
            repo.Name = askTextQuestion("Name of Repo? (DEFAULT: oc-baserepo)", "oc-baserepo")
            repo.RepoIdentifier = askTextQuestion("Use "..repo.Owner.."/"..repo.Name.."? (ENTER) or type custom repo id: ", repo.Owner.."/"..repo.Name)
            --- shortcut name?
            repo.ShortName = askTextQuestion("How will the shortcut be called? (default baserepo): ", "baserepo")
            --- branch name? todo implement downloaing tags
            repo.CurrentBranch = askTextQuestion("please specify branch to download (default master): ", "master")
            repo.CurrentLocalPath = ""

            --- 1. download the actual repo.
            --- 2. find dependencies - if then exist, download and install them
            --- 3. install the actual program
            local installTargetDir  = "/usr/"..repo.Name
            local shortcutTargetDir = "/usr/bin/"
            local downloadTargetDir = DefaultTemporaryDownloadPath..repo.RepoIdentifier
            local manifestTarget = "/etc/manifest/" -- should maybe be "/home/.git-tool/"

            --- FIXME FIXME FIXME
            --- local installedDependencies = legacyInstallDependencies() --only for testing while new version not implemented yet
            --- local installedDependencies = installDependencies(foundDependencies) <<--- This needs to happen after the repo has been downloaded. the repo will need to specify dependencies itself.
            print("downloading "..repo.RepoIdentifier.." from "..repo.Remote.Name)
            local downloadedFiles = downloadRepo(repo, repo.Remote, false, downloadTargetDir) --enable auto-overwrite in other situations still todo
            local installedDependencies = installDependencies(repo)

            local installedFiles = installFiles(downloadedFiles, downloadTargetDir, installTargetDir)
            local installedShortcuts = installShortcut(repo.CurrentLocalPath, repo.ShortName, shortcutTargetDir)

            --- remove temporary files and create manifest for later uninstall
            removeDownloads(downloadTargetDir, downloadedFiles)
            createManifest(installedDependencies, installedFiles, installedShortcuts, manifestTarget, repo.Name)
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
    elseif cliArgs[1] == "-d" then
        setupDefaultInstall()
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
