local image = require("image")
local GUI = require("GUI")

backgroundColor = 0x000000

--start full screen application
local application = GUI.application()
-- Whole Screen application
BackgroundPanel = application:addChild(GUI.panel(1, 1, application.width, application.height, backgroundColor))
--stores the tasks that are being called periodically
RunTasks = {}

function systemButtons(application)
    local systemButtonConfig = {
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
            restartDesktop = {
                idleColor = 0x00FF00,
                pressedColor = 0xBBBBBB,
                textColor = 0x0F0F0F,
                text = "Restart Desktop",
                onTouch = function()
                    application:stop()
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
                    application:removeChildren()
                    application:addChild(GUI.panel(1, 1, application.width, application.height, backgroundColor))
                    application:addChild(GUI.text(1, 1, 0xFFFFFF, "Updater init"))
                    application:draw(true)
                    application:stop()
                    print("Starting Updater...")
                    os.execute("powerman -u -x")
                    print("Going back to GUI")
                    os.sleep(0.5)
                    os.execute("powerman -gui")
                    --graceful Exit
                    os.exit()
                end
            },
            stopGui = {
                idleColor = 0xBB0000,
                pressedColor = 0xBBBBBB,
                textColor = 0x0F0F0F,
                text = "Stop GUI",
                onTouch = function()
                    application:stop()
                end
            },
            openSettings = {
                idleColor = 0xFFFFFF,
                pressedColor = 0xBBBBBB,
                textColor = 0x0F0F0F,
                text = "Settings",
                onTouch = function()
                    LaunchApplication(application, "/usr/PowerManager/applications/settings.lua")
                end
            },
            launchApplications = {
                idleColor = 0xFFFFFF,
                pressedColor = 0xBBBBBB,
                textColor = 0x0F0F0F,
                text = "Launcher",
                onTouch = function()
                    LaunchApplication(application, "/usr/PowerManager/applications/launchApplications.lua")
                end
            },
            closeAll = {
                idleColor = 0xFF0000,
                pressedColor = 0xBBBBBB,
                textColor = 0x0F0F0F,
                text = "Close all Windows",
                onTouch = function()
                    for object in TaskBar.children do
                        object.remove()
                    end
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
    return systemButtonConfig
end
systemButtonConfig = systemButtons(application)

function createSystemButtons(application, config)
    config = config or systemButtonConfig
    --add the systemButtons as container to the application and give them a draw function.
    local systemButtons = application:addChild(GUI.container(1, 1, application.width, (2*systemButtonConfig.padding[2]) + 1))

    local previousButtonLength = 0
    systemButtons:addChild(GUI.panel(1, 1, application.width, (2*config.padding[2]) + 1, 0xBBBBBB))
    for idx, button in pairs(config.buttons) do
        object = systemButtons:addChild(GUI.adaptiveFramedButton( 
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
    return systemButtons
end
systemButtons = createSystemButtons(application)

--Task bar object. Behaves more like a dock with open Windows being shown.
function CreateTaskBar(application, config)
    config = config or {
        backgroundColor = 0xaaaaaa,
    }
    
    local taskBar = application:addChild(GUI.container(1, application.height - 2, application.width, 3))
    taskBar:addChild(GUI.panel(1, 1, taskBar.width, taskBar.height, config.backgroundColor))
    local layoutTaskBar = taskBar:addChild(GUI.layout(1, 1, taskBar.width, taskBar.height, 1, 1))
    layoutTaskBar:setDirection(1, 1, GUI.DIRECTION_HORIZONTAL)
    return layoutTaskBar
end
TaskBar = CreateTaskBar(application)

--To be used on a windowed panel. (GUI.window)
function createCustomWindow(application, x, y, width, height, elementsConfig, runTask, runTaskDelay, stopTask)
    x = x or #TaskBar.children + 10
    y = y or #TaskBar.children + 5
    width = width or 50
    height = height or 20
    runTask = runTask or function() end
    runTaskDelay = runTaskDelay or 5
    stopTask = stopTask or function() end

    --Create window
    local windowObject = application:addChild(GUI.window(x, y, width, height))
    --add the frame animation. When runTaskDelay is over runTask will be called.
    windowObject.animationTask = windowObject:addAnimation(
            function() end,
            function()
                --GUI.alert("DEBUG 171")
                runTask()
                windowObject.animationTask:start(runTaskDelay)
            end
        )
    windowObject.animationTask:start(runTaskDelay)

    elementsConfig = elementsConfig or {
        minimizeButton = {
            idleColor = 0xBBBB00,
            pressedColor = 0x888800,
            textColor = 0xFFFFFF,
            text = "--",
            onTouch = function()
                --set the window as minimized in task Bar and minimize
                windowObject.taskBarIcon.pressed = true
                windowObject:minimize() 
            end
        },
        taskBarIcon = {
            idleColor = 0x000000B,
            pressedColor = 0x888800,
            textColor = 0xFFFFFF,
            text = "",
            onTouch = function() windowObject:minimize() end,
            create = function() 
                --create object to extend taskBar entries
                icon = TaskBar:addChild(GUI.adaptiveButton( 
                    1,0,2,1,
                    elementsConfig.taskBarIcon.idleColor,
                    elementsConfig.taskBarIcon.textColor, 
                    elementsConfig.taskBarIcon.pressedColor, 
                    elementsConfig.taskBarIcon.textColor, 
                    #TaskBar.children))
                icon.switchMode = true
                icon.onTouch = elementsConfig.taskBarIcon.onTouch
                return icon
            end
        },
        closeButton = {
            idleColor = 0xFB0000,
            pressedColor = 0xBB0000,
            textColor = 0xFFFFFF,
            text = "Exit",
            onTouch = function() 
                --remove task bar icon, stop animationTask and close thing
                windowObject.taskBarIcon:remove()
                windowObject.animationTask:stop()
                windowObject:close() 
            end
        },
        titleBar = {
            height = 1,
            backgroundColor = 0x0000BB,
            textColor = 0xFFFFFF,
            text = "Title"
        },
    }
    
    --insert link to self into the TaskBar object
    windowObject.taskBarIcon = elementsConfig.taskBarIcon.create()
    
    windowObject:addChild(GUI.panel(1, 1, windowObject.width, windowObject.height, 0xF0F0F0))
    windowObject:addChild(GUI.panel(1, 1, windowObject.width, elementsConfig.titleBar.height, elementsConfig.titleBar.backgroundColor))
    windowObject.title = windowObject:addChild(GUI.label(2, 1, windowObject.width, elementsConfig.titleBar.height, elementsConfig.titleBar.textColor, elementsConfig.titleBar.text))
    windowObject.minimizer = windowObject:addChild(GUI.adaptiveButton( 
                windowObject.width - (#elementsConfig.closeButton.text + #elementsConfig.minimizeButton.text + 4),
                1,1,0,
                elementsConfig.minimizeButton.idleColor,
                elementsConfig.minimizeButton.textColor, 
                elementsConfig.minimizeButton.pressedColor, 
                elementsConfig.minimizeButton.textColor, 
                elementsConfig.minimizeButton.text))
    windowObject.exit = windowObject:addChild(GUI.adaptiveButton( 
            windowObject.width - #elementsConfig.closeButton.text -1,
            1,1,0,
            elementsConfig.closeButton.idleColor,
            elementsConfig.closeButton.textColor, 
            elementsConfig.closeButton.pressedColor, 
            elementsConfig.closeButton.textColor, 
            elementsConfig.closeButton.text))
        
    windowObject.exit.onTouch = elementsConfig.closeButton.onTouch
    windowObject.minimizer.onTouch = elementsConfig.minimizeButton.onTouch
    return windowObject
end

function LaunchApplication(application, filePath)
    --TODO: Add run method to methods being periodically called by eventHandler.
    --ALSO: Make it so missing apps dont crash the GUI. (pcall?)
    local file = dofile(filePath)
    --most applications should return their window object pointer.
    local initReturn = file.initialize(application)
    --local runTask = file.runTask(application)
    --local onClose = file.onClose(application)
    --table.insert(RunTasks, file.runTask)
    return file, initReturn--, onClose
end

application:draw(true)
application:start()
print("Halted Desktop, returning to Shell...")