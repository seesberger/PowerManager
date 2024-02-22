--Programm um an den PC angeschlossene TE und RF Speicherzellen grafisch darzustellen

local component = require( "component" )
local gpu = component.gpu
local event = require( "event" )

local splashText = "Stromanzeige - Ultimate ROG RGB LED Edition"
local frameTitle = "Power Monitor - Klicken zum Beenden"
 
local oldW, oldH = gpu.getResolution()
local newW = 160
local newH = 50
local numberOfPanels = 2
local panelWidth = (newW / numberOfPanels)
gpu.setResolution(newW, newH)
 
function clearScreen()
  local w,h = gpu.getResolution()
  drawLine(1, 1, w, h, 0x000000)
end


function drawLine(startX, startY, stopX, stopY, colorOfLine)
  local oldColor = gpu.getBackground(false)
  gpu.setBackground(colorOfLine, false)
  gpu.fill(startX, startY, stopX, stopY, " ")
  gpu.setBackground(oldColor, false)
end 
 
function powerBar( label, y, x, value, maxVal, colorOfBar, show, unit, border)
  local oldColor = gpu.getBackground(false)
  local borderSymbol = " "
  local barSymbol = " "
  local percentage = (value * 100 / maxVal)
  local redGraphValue = 20
  
  if percentage <= redGraphValue then
    colorOfBar = 0xf00000
  end
  drawLine(border, y, x, 2, 0x000000)
  w = math.floor( value * (x / maxVal) )
  p = math.floor( (w / x) * 100 )
  gpu.set( border, y, label .. ": " .. tostring( p ) .. "%" )
  drawLine(border, y+1, x, 1, 0x222222)
  drawLine(border, y+1, w, 1, colorOfBar)
  gpu.setBackground( oldColor, false )
  if show then
    local valStr = formatBig( value ) .. unit
    local n = string.len( valStr )
    gpu.set( (x+3) - n, y, valStr )
  end
end
 
 
function formatBig( value )
  local output = ""
  local valRem = 0
  local valPart = 0
  while value > 0 do
    valRem = math.floor( value / 1000 )
    valPart = value - (valRem * 1000)
    if output == "" then
      output = string.format( "%03d", valPart )
    elseif valRem == 0 then
      output = valPart .. "," .. output
    else
      output = string.format( "%03d", valPart ) .. "," .. output
    end
    value = valRem
  end
  return output
end
  
function getCells()
  local countDcOrb = 0
  local countTEcell = 0
  local countRfTCell = 0

  local TEcell = component.list( "energy_device" )
  local RfTCell = component.list("rftools_powercell")

  local cellsID = {}
  
  for address, name in pairs(TEcell) do
    countTEcell =  countTEcell + 1
    if countTEcell > 1 then
      cellsID[address] = "TE Zelle".." "..countTEcell
    else
      cellsID[address] = "TE Zelle"
    end
  end

  for address, name in pairs(RfTCell) do
    countRfTCell = countRfTCell + 1
    if countRfTCell > 1 then
      cellsID[address] = "RfT Zelle".." "..countRfTCell
    else
      cellsID[address] = "RfT Zelle"
    end
  end 
  return cellsID
end

function getTotal()
  local totalPower = 0
  local totalMaxPower = 0
  local cellid = getCells()
  for address, name in pairs(cellid) do
    local cell = component.proxy( address )
    totalPower = totalPower + cell.getEnergyStored()
    totalMaxPower = totalMaxPower + cell.getMaxEnergyStored()
  end
  return totalPower, totalMaxPower

end

function drawPanel(x, y, width, height, color)
  drawLine(x, y, width, height, color)
  drawLine(x + 1, y + 1, width -1, height - 1, 0x000000)
end

function drawDesktop()
  --Title
  local titleHeight = 3
  drawPanel(1, 1, newW, titleHeight, 0xffffff)
  gpu.set((newW - #frameTitle) / 2, 2, frameTitle)
  local cellsID = getCells()
  local count = 0   
  local t = titleHeight

  for i = numberOfPanels - 1, 0, -1 do 
    drawPanel(panelWidth*i+1, titleHeight + 1, newH - titleHeight, 0xffffff)
    if i == 0 then
      for address, name in pairs(cellsID) do
        local cell = component.proxy( address )
        count = count + 1
        t = t + 3
        powerBar( name, t , panelWidth - 6, cell.getEnergyStored(), cell.getMaxEnergyStored() , 0x00bb00, true, "RF", panelWidth*i+2)
      end
    elseif i == 1 then
      local totalPower, totalMaxPower = getTotal()
      powerBar( "Gesamt", titleHeight + 1, panelWidth - 6, totalPower, totalMaxPower, 0x00bb00, true, "RF", panelWidth*i+2)
    end

  end
end

 
clearScreen()
drawLine(1, 1, newW, 1, 0xbbbbbb)
gpu.set((newW - #splashText) / 2, 24, splashText)
os.sleep(1)
clearScreen()

while true do
  local _,_,x,y = event.pull( 1, "touch" )
  drawDesktop()
  if x < 10 and y < 10 then
    numberOfPanels = numberOfPanels + 1
  elseif x > 10 and Y > 10 then
    numberOfPanels = numberOfPanels - 1
  else
    goto quit
  end
end
 
 
::quit::
gpu.setResolution( oldW, oldH )
clearScreen()
print("Programm beendet.")