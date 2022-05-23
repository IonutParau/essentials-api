Essentials = {}

Essentials.version = "1.-1.0"

print("[ Essentials v" .. Essentials.version .. " ]")
print("> Loading low-level assistance...")
On("cell-set", function(cell, x, y, was)
  --love.window.setTitle(tostring(cell))
  FixCell(cell, x, y)
end)

Essentials.posmap = {}

function FixCell(cell, x, y)
  if cell.poskey == nil then
    cell.poskey = love.math.random(1000000)
  end
  cell.x = x
  cell.y = y
  cell.push = function(self, dir, vars)
    return unpack{PushCell(self.x, self.y, dir, vars)}
  end
  cell.pull = function(self, dir, vars)
    return unpack{PullCell(self.x, self.y, dir, vars)}
  end
  cell.grasp = function(self, dir, vars)
    return unpack{GraspCell(self.x, self.y, dir, vars)}
  end
  cell.graspLeft = function(self, dir, vars)
    return unpack{LGraspCell(self.x, self.y, dir, vars)}
  end
  cell.graspRight = function(self, dir, vars)
    return unpack{RGraspCell(self.x, self.y, dir, vars)}
  end
  return cell
end

local oldGetCell = GetCell

function GetCell(x,y)
	return FixCell(oldGetCell(x, y))
end
print("> Loading custom event managers...")
print("> Loading cell makers...")
require("Essentials.cells")
print("> Loading mod loader code...")
require("Essentials.mods")
print("> Loading mods...")
Essentials.LoadMods()