--FIXME: Make it somehow dynamic and maybe use the manifest for Paths?

local args = {...}
args[2] = args[2] or ""
local helpText = "This sophisticated toolset comes packed with a few features: \n"..
                 "Usages:\n"..
                 "powerman              - no args: starts the GUI\n"..
                 "   '' -h              - this help text\n" .. 
                 "   '' -gui            - executes the given file in the Application folder\n"..
                 "   '' -u              - starts the git-tool\n"..
                 "   '' -exe [filename] - executes the given file in the Application folder\n"..
                 "   '' -arb [command]  - executes an arbitrary function that is yet to be defined"

if #args<1 then
    dofile("/usr/PowerManager/main.lua")
    return
end

if args[1] == "-h" then
    print(helpText)
    return
elseif args[1] == "-gui" then
    os.execute("/usr/PowerManager/desktopApplication.lua"..args[2])
elseif args[1] == "-legacy" then
    os.execute("/usr/PowerManager/PowerManagerLegacy.lua"..args[2])
elseif args[1] == "-u" then
    --FIXME: Hardcoded application folder path
    os.execute("/usr/PowerManager/git-tool.lua "..args[2])
    return
elseif args[1] == "-exe" then
    os.execute("/usr/PowerManager/"..args[2])
elseif args[1] == "-arb" then
    os.execute("/bin/"..args[2])
else
    print('"'..args[1]..'" - Bad argument.\nYou can use: powerman -h')
    return
end