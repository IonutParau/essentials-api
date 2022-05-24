Essentials = {}

Essentials.version = "1.-1.0"

local debugMode = false

for _, flag in ipairs(arg) do
  if flag == "--essentialsDebug" then debugMode = true end
end

function Debug(...)
  if debugMode then
    print(...)
  end

  return ...
end

Debug("[ Essentials v" .. Essentials.version .. " ]")
Debug("> Loading low-level assistance...")

local fixID = 0

local posMap = {}

On("cell-set", function(cell, x, y, was)
  --love.window.setTitle(tostring(cell))
  FixCell(cell, x, y)
end)

Essentials.posmap = {}

function FixCell(cell, x, y)
  if cell.poskey == nil then
    cell.poskey = fixID
    fixID = fixID + 1
  end
  posMap[cell.poskey] = {x = x, y = y, dir = cell.rot}
  cell.pos = function(self)
    return posMap[self.poskey]
  end
  cell.dir = function(self)
    return self:pos().dir
  end
  cell.push = function(self, dir, vars)
    return unpack{PushCell(self:pos().x, self:pos().y, dir, vars)}
  end
  cell.pull = function(self, dir, vars)
    return unpack{PullCell(self:pos().x, self:pos().y, dir, vars)}
  end
  cell.grasp = function(self, dir, vars)
    return unpack{GraspCell(self:pos().x, self:pos().y, dir, vars)}
  end
  cell.graspLeft = function(self, dir, vars)
    return unpack{LGraspCell(self:pos().x, self:pos().y, dir, vars)}
  end
  cell.graspRight = function(self, dir, vars)
    return unpack{RGraspCell(self:pos().x, self:pos().y, dir, vars)}
  end
  return cell
end

local oldGetCell = GetCell

function GetCell(x,y)
	return FixCell(oldGetCell(x, y))
end
Debug("> Loading custom event managers...")
require("Essentials.events")
Debug("> Loading cell makers...")
require("Essentials.cells")
Debug("> Loading mod loader code...")
require("Essentials.mods")
Debug("> Loading mods...")
Essentials.LoadMods()