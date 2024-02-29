local image = require("image")
local GUI = require("GUI")
local component = require("component")

--start full screen application
local application = GUI.application()

backgroundColor = 0x0F0F0F
taskBarColor = 0x888888;
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
        restartGui = {
            idleColor = 0x01FF00,
            pressedColor = 0x0B0B0B,
            textColor = 0x0F0F0F,
            text = "Restart Program",
            onTouch = function()
                os.execute("powerman -gui")
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
                os.execute("cls")
                print("Starting Updater...")
                os.execute("powerman -u -x")
                print("Going back to GUI")
                os.sleep(0.5)
                os.execute("powerman -gui")
                os.exit()
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

--FIXME: Janky!
activeWindows = {}
function injectControlButtons(application, controlButtonConfig, buttons)
    buttons = buttons or {
        spawnWindow = {
            idleColor = 0xFFFFFF,
            pressedColor = 0xBBBBBB,
            textColor = 0x0F0F0F,
            text = "Spawn Window",
            onTouch = function()
                window = createCustomWindow(application, #activeWindows + 3, 2 + #activeWindows + 3)
                table.insert(activeWindows, window)
            end
        },
        minimizeAll = {
            idleColor = 0xBB0000,
            pressedColor = 0xBBBBBB,
            textColor = 0x0F0F0F,
            text = "Stop GUI",
            onTouch = function()
                application:stop()
            end
        }
    }
    for idx, button in pairs(buttons) do
        table.insert(controlButtonConfig.buttons, button)
    end
end
injectControlButtons(application, controlButtonConfig)

function createControlButtons(application, config)
    config = config or controlButtonConfig
    --add the controlButtons as container to the application and give them a draw function.
    local controlButtons = application:addChild(GUI.container(1, 1, application.width, (2*controlButtonConfig.padding[2]) + 1))

    local previousButtonLength = 0
    controlButtons:addChild(GUI.panel(1, 1, application.width, (2*config.padding[2]) + 1, taskBarColor))
    for idx, button in pairs(config.buttons) do
        object = controlButtons:addChild(GUI.adaptiveFramedButton( 
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
        previousButtonLength = previousButtonLength + #button.text + 2*config.padding[1]
    end
    return controlButtons
end

--To be used on a windowed panel. (GUI.window)
function createCustomWindow(application, x, y, width, height, elementsConfig, onTouch)
    x = x or 90
    y = y or 10
    width = width or 50
    height = height or 20

    --Create window
    windowObject = application:addChild(GUI.window(x, y, width, height))

    elementsConfig = elementsConfig or {
        closeButton = {
            idleColor = 0xFB0000,
            pressedColor = 0xBB0000,
            textColor = 0xFFFFFF,
            text = "Exit",
            onTouch = function() windowObject:close() end
        },
        titleBar = {
            height = 1,
            backgroundColor = 0x0000BB,
            textColor = 0xFFFFFF,
            text = "Title"
        }
    }
    
    windowObject:addChild(GUI.panel(1, 1, windowObject.width, windowObject.height, 0xF0F0F0))
    windowObject:addChild(GUI.panel(1, 1, windowObject.width, elementsConfig.titleBar.height, elementsConfig.titleBar.backgroundColor))
    windowObject:addChild(GUI.label(2, 1, windowObject.width, elementsConfig.titleBar.height, elementsConfig.titleBar.textColor, elementsConfig.titleBar.text))
    close = windowObject:addChild(GUI.adaptiveButton( 
            windowObject.width - #elementsConfig.closeButton.text -1,
            1,1,0,
            elementsConfig.closeButton.idleColor,
            elementsConfig.closeButton.textColor, 
            elementsConfig.closeButton.pressedColor, 
            elementsConfig.closeButton.textColor, 
            elementsConfig.closeButton.text))
    close.onTouch = elementsConfig.closeButton.onTouch
    return windowObject, close
end


-- Whole Screen application
application:addChild(GUI.panel(1, 1, application.width, application.height, backgroundColor))

controlButtons = createControlButtons(application)

window1 = createCustomWindow(application)
-- Add a background panel and text widget to it
window1:addChild(GUI.text(2, 3, 0x2D2D2D, "Hier könnte Ihre Werbung stehen!"))
local layoutWindow1 = window1:addChild(GUI.layout(2, 1, window1.width, window1.height - 2, 1, 1))
progressbarWindow1 = layoutWindow1:addChild(GUI.progressBar(1, 1, window1.width, 0x3366CC, 0xEEEEEE, 0x000000, 50, true, true, "Fick-Dich-Meter: ", ""))
buttonProgressbarUp = layoutWindow1:addChild(GUI.button(1, 1, window1.width, 3, 0xB4B4B4, 0xFFFFFF, 0x969696, 0xB4B4B4, "+++"))
buttonProgressbarDn = layoutWindow1:addChild(GUI.button(1, 1, window1.width, 3, 0xB4B4B4, 0xFFFFFF, 0x969696, 0xB4B4B4, "---"))

buttonProgressbarUp.onTouch = function()
    progressbarWindow1.value = progressbarWindow1.value + 5
end
buttonProgressbarDn.onTouch = function()
    progressbarWindow1.value = progressbarWindow1.value - 5
end

application:draw(true)
application:start()
print("Halted Desktop, returning to Shell...")