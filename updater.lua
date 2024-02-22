
print("Updaten? (Y/*)")
local abfrage = term.read()

if abfrage == "Y" then
    print("Ja!")
    --os.execute("gitrepo seesberger/PowerManager /home/PowerManager")
else
    print("Nein!")
    os.sleep(1)
end

