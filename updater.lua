
print("Updaten? (Y/*)")
local abfrage = io.read()

if abfrage == "Y" then
    print("Update und Installationsprogramm werden abgerufen...")
    os.execute("gitrepo seesberger/PowerManager /home/PowerManager")
    dofile("/home/installer.lua")
else
    print("Ohne Update fortfahren...")
    os.sleep(1)
end

