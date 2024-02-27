local args = {...}
local helpText = "This sophisticated toolset comes packed with a few features: \n"..
                 "Usages:\n"..
                 "powerman              - no args: starts the GUI\n"..
                 "   '' -h              - this help text\n" .. 
                 "   '' -u              - starts the git-tool"..
                 "   '' -exe [filename] - executes the give file in the Application folder"..
                 "   '' -arb [command]  - executes an arbitrary function that is yet to be defined"

if #args<1 then
    dofile("/usr/PowerManager/main.lua")
    return
end

if args[1] == "-h" then
    print(helpText)
    return
elseif args[1] == "-exe" then
    if #args == 2 then
        os.execute("/usr/PowerManager/"..args[2])
        return
    end
    os.execute("/usr/PowerManager/updater.lua -a")
    return
else
    print('"'..args[1]..'" - Bad argument.\nYou can use: powerman -h')
    return
end