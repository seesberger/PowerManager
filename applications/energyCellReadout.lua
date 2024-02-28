
function getCells()
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

function getCellPercentage(cell)
    val = (cell.getEnergyStored() * 100) / cell.getMaxEnergyStored()
    return val
end

cellsProgressBars = {}
function drawCellsAsContent(obj)
    for address, name in pairs(getCells()) do
        local cell = component.proxy( address )
        progressbar = obj:addChild(GUI.progressBar(1, 1, obj.width - 2, 0x3366CC, 0xEEEEEE, 0x000000, getCellPercentage(cell) , true, true, name, " RF"))
        table.insert(cellsProgressBars, progressbar)
    end
end
local progressbars = application:addChild(GUI.titledWindow(50, 10, 40, 30, "-Cells", true))
drawCellsAsContent(progressbars)