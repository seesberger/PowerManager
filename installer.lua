local headerText = "PowerManager - Installer\n"
local startOnBootText = "Beim Boot ausführen?"
local automaticUpdateText = "Automatisch updates herunterladen?"

--returns the user input as bool (Y/N) -> (1/0)
local function askThatDamnUser(prompt)
    while true do
        print(">>> " .. prompt)
        local userInput = io.read()

        if userInput == "Y" then
            return true
        elseif userInput == "N" then
            return false
        else
            print("Hallo? => ( Y / N ) Nicht -> " .. userInput)
        end
    end
end


local startOnBoot = askThatDamnUser(startOnBootText)
local automaticUpdate = askThatDamnUser(automaticUpdateText)

if startOnBoot then
    print("notImplementedYet")
end
if automaticUpdate then
    print("notImplementedYet")
end

os.execute("mv shortcut.lua /usr/bin/powerman.lua")