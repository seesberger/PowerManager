
local version="0.0.1a"
local author="Frederick"
---

local computer=require"computer"
local gui=require"GUI"

gui.initialize()
local w,h = gui.getResolution()
local start_time = computer.uptime()
local running = true

gui.show()

--Usage? (no good docs)
--labelbox(x, y, w, h, layer, fColor, bColor, clickEvent, ?, text)
--when nil is used most params have standard values you can globally adjust.

--initiate this object using: [Name] = windows:new()
windows = {
    name = "",
    title = "Name",
    titleForegroundColor = 0xFFFFFF,
    titleBackgroundColor = 0x0000bb,
    contentBackgroundColor = 0x0F0F0F,
    exitTextBackgroundColor = 0xFF0000,
    exitText = "Exit",
    titleHeight = 0, --0 = 1 line high
    size = { 100, 20},
    position = { 10, 10},
    layer = 105,

    closeable = true,
    defaultContents = function(self)
        c = {
            self:drawTitle(), 
            self:drawPanel(),
            self:drawButton(1, 1, "+", 0x00FF00, function() self:moveWindowUp() end),
            self:drawButton(1, 2, "-", 0x0000FF, function() self:moveWindowDown() end),
            self:drawButton(1, 3, ">", 0x00BB00, function() self:moveWindowR() end),
            self:drawButton(1, 4, "<", 0x0000BB, function() self:moveWindowL() end)
            }
        return c end,

    activeObjects = {},
    --are there pending changes on the position?
    --changes = false,

    --TODO: at the moment this exits the gui. Maybe make it delete this object?
    exit = function(self) if self.closeable == true then self:deleteWindow() end end,

    moveWindowR = function(self) self:updateWindow(1) end,
    moveWindowL = function(self) self:updateWindow(-1) end,
    moveWindowUp = function(self) self:updateWindow(nil, -1) end,
    moveWindowDown = function(self) self:updateWindow(nil, 1) end,
    moveToForeground = function(self) self:updateWindow(nil, nil, 10) end,

    insertActiveObjectToTable = function(self, obj) table.insert(self.activeObjects, obj) end,

    drawTitle = function(self)
        titlebar = gui.labelbox(self.position[1], 
                                self.position[2], 
                                self.size[1] - #self.exitText - 1, 
                                self.titleHeight,
                                self.layer, 
                                self.titleForegroundColor, 
                                self.titleBackgroundColor, 
                                function() self:moveToForeground() end, nil,
                                self.title)
        exit = gui.labelbox(self.position[1] + (self.size[1] - #self.exitText),
                            self.position[2],
                            #self.exitText,
                            self.titleHeight,
                            self.layer, 
                            self.titleForegroundColor, 
                            self.exitTextBackgroundColor, 
                            function() self:exit() end, nil,
                            self.exitText)
        self:insertActiveObjectToTable(exit)
        self:insertActiveObjectToTable(titlebar)
    end,

    drawPanel = function(self)
        contentPanel = gui.rect_full(self.position[1], 
                                        self.position[2] + 1, 
                                        self.size[1], 
                                        self.size[2] - 1,
                                        self.layer - 1, --Background has to be in the Background... duh...
                                        nil, --no text => no foreground color
                                        self.contentBackgroundColor)
        self:insertActiveObjectToTable(contentPanel)
    end,

    --use relX and relY with  to align relative to window
    drawButton = function(self, relX, relY, description, color, clickEvent)
        if relX > self.size[1] then relX = self.size[1] end
        if relY > self.size[2] then relY = self.size[2] end
        absX = self.position[1] + (relX)
        absY = self.position[2] + (relY)
        button = gui.labelbox(  absX, 
                                absY, 
                                #description, 
                                0,
                                self.layer, 
                                nil, 
                                color, 
                                clickEvent, nil,
                                description)
        self:insertActiveObjectToTable(button)
        return button
    end,

    insertObjectToContents = function(self, object)
        content = self:windowContents()
        table.insert(content, object)
        function self:windowContents()
            b = content
            return b
        end
    end,

    resetContents = function(self)
        function self:windowContent()
            b = self:defaultContents()
            return b
        end
    end,

    --do it my boy, draw it!
    drawProgressBar = function(self, relX, relY, value, maxValue, description, width, color, backgroundColor, warningThreshold)
        color = color or 0x00FF00
        warningThreshold = warningThreshold or 20
        description = description or "Name"
        width = width or 10
        backgroundColor = backgroundColor or self.contentBackgroundColor
        percentage = (value*100)/maxValue
        if percentage < warningThreshold then color = 0xBB0000 end

        if relX > self.size[1] then relX = self.size[1] end
        if relY > self.size[2] then relY = self.size[2] end
        absX = self.position[1] + (relX)
        absY = self.position[2] + (relY)

        outline = gui.labelbox( absX, 
                                absY, 
                                width, 
                                1,
                                self.layer, 
                                nil, 
                                backgroundColor, 
                                nil, nil,
                                description)
        bar = gui.labelbox (absX,
                            absY + 1,
                            math.floor((width * percentage) / 100),
                            0,
                            self.layer, 
                            nil, 
                            color)
        self:insertActiveObjectToTable(outline)
        self:insertActiveObjectToTable(bar)
    end,
    
    --insert wanted content into this table.
    windowContents = function(self)
        b = self:defaultContents()
        return b end,

    --Init Window
    drawWindow = function(self)
        self.activeObjects = {}
        for i, method in ipairs(self:windowContents()) do
            method()
        end
    end,

    --used for updating the contents when moved (args may be nil for content updates)
    updateWindow = function(self, x, y, layer)
        for i, object in ipairs(self.activeObjects) do
            object.move(x, y, layer)
            --object.update()
        end
    end,

    rebootWindow = function(self)
        self:deleteWindow()
        self:drawWindow()
    end,

    --delete all window objects
    deleteWindow = function(self)
        for i, object in ipairs(self.activeObjects) do
            object.remove(false) --remove all objects and show layers behind it
        end
    end,

    -- Constructor
    new = function(self, name, o)
        self.__index = self
        o = o or {}
        local inst = setmetatable(o, self)
        inst.name = name
        self.title = name
        return inst
    end
}

Window1 = windows:new("Win1")
Window2 = windows:new("Win2")
ExitWindow = windows:new("Exit")

Window2.size = {50, 10}
Window2.position = {1, 1}
Window2.layer = 101
Window2.titleBackgroundColor = 0x00bb00

ExitWindow.size = {30, 10}
ExitWindow.position = {100, 1}
ExitWindow.closeable = false
ExitWindow.contentBackgroundColor = 0xbbbbbb
ExitWindow:insertObjectToContents(ExitWindow:drawButton(5, 1, "Exit GUI", 0xFF0000, function() running = false end))
Window1:insertObjectToContents(Window1:drawProgressBar(5, 3, 25, 100, "TestBar", 10))


Window1:drawWindow()
Window2:drawWindow()
ExitWindow:drawWindow()

while running do
    os.sleep(0.2)
    --just loop. put some looping shit here!
end
--os.execute("reboot")
gui.stopGUI()
os.exit()