
local version="0.0.1a"
local author="Frederick"
---

local computer=require"computer"
local gui=require"GUI"

gui.initialize()
local w,h = gui.getResolution()
local start_time = computer.uptime()
local clickcount = 0
local running = true

local function incCount()
    clickcount=clickcount+1
    click_counter.setText("Clickcounter: %i",clickcount)
end

local function moveR1() test1.move(1) end
local function moveL1() test1.move(-1) end
local function moveUp1() test1.move(nil,-1) end
local function moveDown1() test1.move(nil,1) end
local function layerUp1() test1.move(nil,nil,1) showl1.setText("Layer yellow: %i",test1.getLayer()) end
local function layerDown1() test1.move(nil,nil,-1) showl1.setText("Layer yellow: %i",test1.getLayer()) end
local function moveR2() test2.move(1) end
local function moveL2() test2.move(-1) end
local function moveUp2() test2.move(nil,-1) end
local function moveDown2() test2.move(nil,1) end
local function layerUp2() test2.move(nil,nil,1) showl2.setText("Layer blue:   %i",test2.getLayer()) end
local function layerDown2() test2.move(nil,nil,-1) showl2.setText("Layer blue:   %i",test2.getLayer()) end
local function exitGUI() running=false end
local function chgFCol() gui.setStdForeColor(0xFF0000) end
local function chgStdCol() gui.setStdForeColor(0xFFFFFF) end
local function textoutput(x,y,button,user,text) textoutput_shape.setText(text) end

gui.show()
--[[
welcome=gui.label(math.floor(w/3),2,math.floor(w/3),4,nil,nil,nil,nil,nil,"Welcome to the tech demo of my GUI-API!\nI hope you enjoy it and get a taste of its potential,\nwell it is still beta..\ncould kill penguins, burn your house etc...:D")
features=gui.labelbox(2,8,w-4,9,101,nil,0x00AAFF,nil,nil,"Some general features in beta:\nObject oriented, Layer support, Reference system\n\nSo in understandable words:\nYou can move objects, resize objects, change their layer, bind a text to a rect so they move and resize together,...\n\nCurrently added shapes:\nRect, Label, Labelbox, Listing, Textbox (working, but has some glitches)\nThe Community is encouraged to contribute shapes!")
counter=gui.label(w-20,1,20,1,101,nil,nil,nil,nil,"Current uptime: %.1f",computer.uptime()-start_time)
click_counter=gui.label(w-20,2,20,0,101,nil,nil,nil,nil,"Clickcounter: %i",clickcount)
clickbox=gui.labelbox(w/2-5,20,10,2,101,nil,0xFFAA00,incCount,nil,"Click me!")
clickbox.moveText(1,1)
exit=gui.labelbox(w-3,h,3,1,101,nil,0x00AAAA,exitGUI,nil,"Exit")
test1=gui.rect_full(70,30,20,10,nil,nil,0xFFFF00)
test2=gui.rect_full(80,35,20,10,101,nil,0x00FFFF)
moveR1l=gui.labelbox(6,h-6,4,0,101,nil,0x00AAFF,moveR1,nil,"Right")
moveL1l=gui.labelbox(2,h-6,3,0,101,nil,0x00AAF0,moveL1,nil,"Left")
moveUp1l=gui.labelbox(5,h-7,1,0,101,nil,0x00AA0F,moveUp1,nil,"Up")
moveDown1l=gui.labelbox(4,h-5,3,0,101,nil,0x00AAF0,moveDown1,nil,"Down")
layerUp1l=gui.labelbox(3,h-10,6,0,101,nil,0x00AAFF,layerUp1,nil,"LayerUp")
layerDown1l=gui.labelbox(2,h-9,8,0,101,nil,0x00AA00,layerDown1,nil,"LayerDown")
moveR2l=gui.labelbox(18,h-6,4,0,101,nil,0x00AAFF,moveR2,nil,"Right")
moveL2l=gui.labelbox(14,h-6,3,0,101,nil,0x00AAF0,moveL2,nil,"Left")
moveUp2l=gui.labelbox(17,h-7,1,0,101,nil,0x00AA0F,moveUp2,nil,"Up")
moveDown2l=gui.labelbox(16,h-5,3,0,101,nil,0x00AAF0,moveDown2,nil,"Down")
layerUp2l=gui.labelbox(15,h-2,6,0,101,nil,0x00AA00,layerUp2,nil,"LayerUp")
layerDown2l=gui.labelbox(14,h-3,8,0,101,nil,0x00AAFF,layerDown2,nil,"LayerDown")
showl1=gui.label(5,h-15,16,0,101,nil,nil,nil,nil,"Layer yellow: %i",test1.getLayer())
showl2=gui.label(5,h-14,16,0,101,nil,nil,nil,nil,"Layer blue:   %i",test2.getLayer())
local t="change foreground color to "
local f="0xFF0000"
changeFCol=gui.labelbox(3,20,16,1,101,nil,0xFFAAFF,chgFCol,nil,t..f)
changeStdCol=gui.labelbox(3,23,16,1,101,nil,0xFFAAFF,chgStdCol,nil,t.."standard")
scrollbox=gui.listing(w-10,30,8,4,101,nil,0x00FFAA,nil,nil,{"Scroll me!","This is a long text so you can test the scrolling feature","And to show you the listing shape"})
textinput=gui.textbox(w-10,36,8,4,101,nil,0xFFAA00,textoutput,nil,"insert text")
textoutput_shape=gui.labelbox(w-10,42,8,5,101,nil,0xFF00AA,nil,nil,"input will be here")
]]

--Usage? (no good docs)
--labelbox(x, y, w, h, layer, fColor, bColor, clickEvent, ?, text)
--when nil is used most params have standard values you can globally adjust.

--initiate this object using: [Name] = windows()
function windows()
    --chose "a" for better readability
    a = {
        title = "Name",
        titleForegroundColor = 0xFFFFFF,
        titleBackgroundColor = 0x0000bb,
        contentBackgroundColor = 0x000000,
        exitTextBackgroundColor = 0xFF0000,
        exitText = "Exit",
        titleHeight = 1,
        size = { 50, 50},
        position = { 1, 1},
        layer = 105,
        --ar there pending changes on the position?
        changes = false,

        --TODO: at the moment this exits the gui. Maybe make it delete this object?
        exit = function() running = false end,
        
        moveWindowR = function(self) self.position[1] = self.position[1] + 1 self.changes = true end,
        moveWindowL = function(self) self.position[1] = self.position[1] - 1 self.changes = true end,
        moveWindowUp = function(self) self.position[2] = self.position[2] - 1 self.changes = true end,
        moveWindowDown = function(self) self.position[2] = self.position[2] + 1 self.changes = true end,
        moveToForeground = function(self) self.layer = self.layer + 1 self.changes = true end,

        drawTitle = function(self)
            titlebar = gui.labelbox(self.position[1], 
                                    self.position[2], 
                                    self.size[1] - #a.exitText - 1, 
                                    self.titleHeight,
                                    self.layer, 
                                    self.titleForegroundColor, 
                                    self.titleBackgroundColor, 
                                    self.moveToForeground, nil,
                                    self.title)
            exit = gui.labelbox(self.position[1] + (self.size[1] - #self.exitText),
                                self.position[2],
                                #self.exitText,
                                self.titleHeight,
                                self.layer, 
                                self.titleForegroundColor, 
                                self.exitTextBackgroundColor, 
                                self.exit, nil,
                                self.exitText)
        end,
        drawPanel = function(self)
            contentPanel = gui.rect_full(self.position[1], 
                                         self.position[2] + 1, 
                                         self.size[1], 
                                         self.size[2] - 1,
                                         self.layer - 1, --Background has to be in the Background... duh...
                                         nil, --no text => no foreground color
                                         self.contentBackgroundColor)
        end,

        --use relX and relY with  to align relative to window
        drawButton = function(self, relX, relY, description, color, clickEvent)
            absX = self.position[1] + (self.size[1]/relX)
            absY = self.position[1] + (self.size[1]/relY)
            button = gui.labelbox(  absX, 
                                    absY, 
                                    #description, 
                                    1,
                                    self.layer, 
                                    nil, 
                                    color, 
                                    clickEvent, nil,
                                    description)
        end,
        
        --insert wanted content into this table.
        windowContents = function(self)
            b = {self:drawTitle(), 
                self:drawPanel(), 
                self:drawButton(0.1, 0.3, "Hoch", 0x00FF00, self.moveWindowUp),
                self:drawButton(0.1, 0.1, "Runter", 0x0000FF, self.moveWindowDown)}
        return b end,
        
        --used for updating the contents
        drawWindow = function(self)
            for i, method in ipairs(self:windowContents()) do
                method()
            end
            self.changes = false
        end
        
    }
    return a
end

Window1 = windows()
Window1:drawWindow()

while running do
    os.sleep(0.2)
    if Window1.changes then
        Window1:drawWindow()
    end
end
gui.stopGUI()
os.exit()