local image = require("image")
local GUI = require("GUI")
local component = require("component")

backgroundColor = 0x0F0F0F
taskBarColor = 0xBBBBBB;
controlButtonConfig = {
    --absolute position of the button array
    position = { 1, 1},
    --padding of the individual buttons
    padding = { 2, 1},

    buttons = {
        shutdown = {
            idleColor = 0x0000BB,
            pressedColor = 0x00000B,
            textColor = 0x0F0F0F,
            text = "Reboot",
            onTouch = function()
                os.execute("reboot")
            end
        },
        exitGui = {
            idleColor = 0xBB0000,
            pressedColor = 0x0B0000,
            textColor = 0x0F0F0F,
            text = "Exit to shell",
            onTouch = function()
                os.exit()
            end
        },
        restartGui = {
            idleColor = 0x01FF00,
            pressedColor = 0x0B0B0B,
            textColor = 0x0F0F0F,
            text = "Restart Program",
            onTouch = function()
                os.execute("powerman -exe desktopApplication")
                os.exit()
            end
        },
        updateApplication = {
            idleColor = 0xFFFFFF,
            pressedColor = 0xBBBBBB,
            textColor = 0x0F0F0F,
            text = "Update",
            onTouch = function()
                --FIXME: Change text color to mitigate unreadable text
                os.exit()
                os.execute("cls")
                os.execute("powerman -u -x")
            end
        }
        --[[
        template = {
            idleColor = 0xFFFFFF,
            pressedColor = 0xBBBBBB,
            textColor = 0x0F0F0F,
            text = "Template",
            onTouch = function()
                --do stuff
            end
        }
        ]]
    }
}
controlButtons = {}
function createControlButtons(application, config)
    config = config or controlButtonConfig
    local previousButtonLength = 0
    application:addChild(GUI.panel(1, 1, application.width, (2*config.padding[2]) + 1, taskBarColor))
    for i, button in pairs(config.buttons) do
        object = application:addChild(GUI.adaptiveFramedButton( 
            previousButtonLength + config.position[1],
            config.position[2],
            config.padding[1],
            config.padding[2],
            button.idleColor,
            button.textColor, 
            button.pressedColor, 
            button.textColor, 
            button.text
            ))
        object.onTouch = button.onTouch
        table.insert(controlButtons, object)
        previousButtonLength = previousButtonLength + #button.text + 2*config.padding[1]
    end
end

--To be used on a windowed panel. (GUI.window)
function createCustomWindow(obj, elementsConfig, onTouch)
    elementsConfig = elementsConfig or {
        closeButton = {
            idleColor = 0xFB0000,
            pressedColor = 0xBB0000,
            textColor = 0xFFFFFF,
            text = "Exit"
        },
        titleBar = {
            height = 1,
            backgroundColor = 0x000F0F,
            textColor = 0xFFFFFF,
            text = "Title"
        }
    }
    
    obj:addChild(GUI.panel(1, 1, obj.width, obj.height, 0xF0F0F0))
    obj:addChild(GUI.panel(1, 1, obj.width, elementsConfig.titleBar.height, elementsConfig.titleBar.backgroundColor))
    obj:addChild(GUI.label(2, 1, obj.width, elementsConfig.titleBar.height, elementsConfig.titleBar.textColor, elementsConfig.titleBar.text))
    close = obj:addChild(GUI.adaptiveFramedButton( 
            obj.width - #elementsConfig.closeButton.text,
            1,0,0,
            elementsConfig.closeButton.idleColor,
            elementsConfig.closeButton.textColor, 
            elementsConfig.closeButton.pressedColor, 
            elementsConfig.closeButton.textColor, 
            elementsConfig.closeButton.text))
    close.onTouch = function() obj:close() end
    return close
end

local application = GUI.application()

-- Whole Screen application
application:addChild(GUI.panel(1, 1, application.width, application.height, backgroundColor))

createControlButtons(application)

-- First, add an empty window to application
local window1 = application:addChild(GUI.window(90, 6, 60, 20))
createCustomWindow = createCustomWindow(window1)
-- Add a background panel and text widget to it
window1:addChild(GUI.text(2, 3, 0x2D2D2D, "Hier könnte Ihre Werbung stehen!"))
local layoutWindow1 = window1:addChild(GUI.layout(2, 1, window1.width, window1.height - 2, 1, 1))
progressbarWindow1 = layoutWindow1:addChild(GUI.progressBar(1, 1, window1.width, 0x3366CC, 0xEEEEEE, 0x000000, 50, true, true, "Fick-Dich-Meter: ", ""))
buttonProgressbarUp = layoutWindow1:addChild(GUI.button(1, 1, 50, 3, 0xB4B4B4, 0xFFFFFF, 0x969696, 0xB4B4B4, "+++"))
buttonProgressbarDn = layoutWindow1:addChild(GUI.button(1, 1, 50, 3, 0xB4B4B4, 0xFFFFFF, 0x969696, 0xB4B4B4, "---"))

buttonProgressbarUp.onTouch = function()
    progressbarWindow1.value = progressbarWindow1 + 2
end
buttonProgressbarDn.onTouch = function()
    progressbarWindow1.value = progressbarWindow1 - 2
end

application:draw(true)
application:start()
print("Halted Desktop")