
print("Updaten? (Y/*)")
local abfrage = io.read()

if abfrage == "Y\n" then
    print("Ja!")
    os.execute("gitrepo seesberger/PowerManager /home/PowerManager")
else
    print("Nein!")
    os.sleep(1)
end

