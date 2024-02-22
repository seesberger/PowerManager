local greetingText =    "Dieser Installer begleitet Sie für wenige Sekunden bei der Installation eines sehr coolen Programmes. Bitte tun Sie, was das Programm sagt, sonst wird es sauer."
local headerText = "PowerManager - Installer\n"
local startOnBootText = "Beim Boot ausführen?"
local automaticUpdateText = "Automatisch updates herunterladen?"

--returns the user input as bool (Y/N) -> (1/0)
local function askThatDamnUser(prompt)
    while true do
        print(">>> " .. prompt)
        local userInput = term.read()

        if userInput == "Y\n" then
            return true
        elseif userInput == "N\n" then
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