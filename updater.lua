local args = {...}
local internet=require("internet")
local filesystem=require("filesystem")
local unicode=require("unicode")

YES = {"y","yes","Y","Yes","YES"}
NO = {"n","no","N","No","NO"}

SupportedRemotes = {
    Github = {
        BaseUrl = "https://github.com/",
        Implemented = true
    },
    Gitea = {
        BaseUrl = "https://git.realrobin.io",
        Implemented = false
    }
}

Repository = {}

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
        for idx, val in array do
            if value == val then return true
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
end

local function askTextQuestion(question, defaultAnswerOnEnter, allowOnly)
    local allowedInputsString = ""
    for idx, entry in allowOnly do allowedInputsString = allowedInputsString..entry end
    if allowOnly then print(question.." ["..allowedInputsString.."]")
    else print(question) end
    local userInput = nil
    local found = false
    repeat
        userInput = io.read("l")
        if allowOnly then
            for idx, entry in allowOnly do if entry == userInput then found = true end end
        else break end
    until found
    if userInput == "" then return defaultAnswerOnEnter else return userInput end
end

--- todo: pcall and catch errors
local function downloadRepo(repository, autoOverride)

    local function validateRepositoryIdentifier(repository)
        if not repository.RepoIdentifier:match("^[%w-.]*/[%w-.]*$") then
            print('"'..repository.RepoIdentifier..'" does not look like a valid repo identifier.\nShould be <owner>/<reponame>')
            return
        end 
    end

    validateRepositoryIdentifier(repository)

    local function makeDirIfNotExists(target)
        if filesystem.exists(target) then
            if not filesystem.isDirectory(target) then error("target directory already exists and is not a directory.") end
            if filesystem.get(target).isReadOnly() then error("target directory is read-only.") end
        else
            if not filesystem.makeDirectory(target) then error("directory creation failed") end
        end
    end

    --- FIXME: If download only mode is enabled, set this to /home. still todo
    local targetDownloadPath = DefaultTemporaryDownloadPath..repository.RepoIdentifier
    repository.CurrentLocalPath = targetDownloadPath
    local success, err = pcall(makeDirIfNotExists, targetDownloadPath)
    if not success then error("the download failed because of filesystem errors.") end

    local function fetchFilesAndSubdirs(repository, remoteType, dir)
        dir = dir or "" -- default value, start at root dir
        if remoteType == SupportedRemotes.Github then
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

                local subfiles,subdirs=fetchFilesAndSubdirs(repository.RepoIdentifier,dir.."/"..t[i].name)
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
    local files,dirs=fetchFilesAndSubdirs(repository.RepoIdentifier, "", SupportedRemotes.Github)
    for i=1,#dirs do
        local success, err = pcall(makeDirIfNotExists, targetDownloadPath..dirs[i])
        if not success then error(("the download failed because of filesystem errors. %x"):format(err)) end
    end

    local replaceMode="ask"
    if autoOverride == true then replaceMode = "always" end

    local function downloadFiles(files, targetDownloadPath, replaceMode)
        for i=1,#files do
            local replace=nil
            if filesystem.exists(targetDownloadPath..files[i]) then
                --- FIXME dir löschen statt error
                if filesystem.isDirectory(targetDownloadPath..files[i]) then error("file "..targetDownloadPath..files[i].." blocked by directory with same name!") end
                if not replaceMode == "ask" then
                    replace = (replaceMode=="always")
                    replace = not (replaceMode=="never")
                end
                else print("\nFile "..targetDownloadPath..files[i].." already exists.\nReplace with new version?") end
                local response=""
                if replace == nil then
                    --- FIXME: ggf falsch und buggy
                    local userInput = askTextQuestion("\nFile "..targetDownloadPath..files[i].." already exists.\nReplace with new version?","n",{"y","n","A","S"})

                    if userInput=="A" then
                    replaceMode="always"
                    userInput="y"
                    elseif userInput=="S" then
                    replaceMode="never"
                    userInput="n"
                    elseif userInput == "y" then replace=true
                    elseif userInput == "n" then replace=false
                    end
                end
                if replace then filesystem.remove(targetDownloadPath..files[i]) end
            if replace or replace == nil then
                --- TODO @Freddy: Coole Animation hinzufügen
                print("downloading file "..files[i])
                local url=repository.Remote.BaseUrl..repository.Name.."/"..repository.CurrentBranch..files[i]
                local success,response=pcall(internet.request,url)
                if success then
                    local raw=""
                    for chunk in response do
                        raw=raw..chunk
                    end
                    print("writing to "..targetDownloadPath..files[i])
                    local file=io.open(targetDownloadPath..files[i],"w")
                    if file then -- might be nil under wierd circumstances
                        file:write(raw)
                        file:close()
                    end
                else error("a file did not download correctly. aborting") end
            end
        end
    end

    success, err = pcall(downloadFiles, files, targetDownloadPath, replaceMode)
    if success then print("All files downloaded successfully.") else error(err) end
end

local function installShortcut(currentRepoPath, shortcutName)
    print("installing shortcut...")
    os.execute("mv "..currentRepoPath.."shortcut.lua /usr/bin/"..shortcutName..".lua")
end

--- todo: automatic read of dependency list (txt file containing lines with <link> <dst> or somethink like it)
--- removeme
local function legacyInstallDependencies(enabled)
    if enabled==true then
        os.execute("wget -f https://github.com/kevinkk525/OC-GUI-API/raw/master/shapes_default.lua /lib/shapes_default.lua")
        os.execute("wget -f https://github.com/kevinkk525/OC-GUI-API/raw/master/GUI.lua /lib/GUI.lua")
        os.execute("wget -f https://github.com/kevinkk525/OC-GUI-API/raw/master/term_mod.lua /lib/term_mod.lua")
        os.execute("wget -f https://github.com/kevinkk525/OC-GUI-API/raw/master/tech_demo.lua /home/GUI_tech_demo.lua")
    end
end

--- fix legacy shit
local function runFullInstallTask(repository)
    --- first, download the actual repo.
    --- then, find dependencies - if then exist, download and install them
    --- then, install the actual program
    legacyInstallDependencies(true) --only for testing while new version not implemented yet
    print("downloading "..repository.RepoIdentifier)
    downloadRepo(repository, false) --enable autooverwrite in other situations still todo
    installShortcut(repository.CurrentLocalPath)
end

local function printHelpText()
    local helpText =        "This updater pulls the git files for installation and application updates.\n"..
    "Usage:\n" ..
    "updater <option>  - no args: manual update and install\n"..
    "  '' -h or --help - this help text"
    print(helpText)
end

local function run(cliArgs)
    if #cliArgs<1 then
        print("No Arguments given. For help, please check -h or --help")
        return
    end
    if cliArgs[1] == ("-h" or "--help") then
        printHelpText()
        return
    elseif cliArgs[1] == ("--setup-default") then
        --- ask user about repo
        Repository = DefaultRepository
        if askYesOrNoQuestion("Use default config? (github::seesberger/PowerManager)?",YES,NO,true) then runFullInstallTask(Repository) end
        return
    else
        print('"'..cliArgs[1]..'" - Bad argument. Try --help')
        return
    print("Program exited.")
    end
end

run(args)
