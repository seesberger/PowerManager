local args = {...}
local helpText = "This is a tool for displaying and managing your Power cells and generators.\n"..
                 "Usages:"..
                 "powerman <option> - no args: starts the application"..
                 "   ''       -h    - this help text\n" .. 
                 "   ''     update <update argument>"



if #args<1 then
    dofile("/usr/PowerManager/main.lua")
    return
end

if args[1] == "-h" then
    print(helpText)
    return
elseif args[1] == "update" then
    if #args == 2 then
        os.execute("/usr/PowerManager/updater.lua "..args[2])
        return
    end
    os.execute("/usr/PowerManager/updater.lua -a")
    return
else
    print('"'..args[1]..'" - Bad argument.\nYou can use: powerman -h')
    return
end