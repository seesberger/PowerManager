local args = {...}
local helpText = "This is a tool for displaying and managing your Power cells and generators."


if #args<1 then
    dofile("/usr/PowerManager/main.lua")
    return
end

if args[1] == "-h" then
    print(helpText)
    return
elseif args[1] == "update" then
    os.execute("/usr/PowerManager/updater.lua -a")
    return
else
    print('"'..args[1]..'" - Bad argument. you can use: powerman update')
    return
end