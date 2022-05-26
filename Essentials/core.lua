Essentials = {}

Essentials.version = "1.-1.1"

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
Debug("Added cell setting event")

local oldRotateCell = RotateCell

function RotateCell(x, y, rot, dir, amount)
  oldRotateCell(x, y, rot, dir, amount)
  local c = GetCell(x, y)
  FixCell(c, x, y)
end
Debug("Injected into RotateCell()")

Essentials.posmap = {}
Essentials.customFixes = {}

function Essentials.AddCustomFix(fix, func)
  Essentials.customFixes[fix] = func
end

function Essentials.RemoveCustomFix(fix, func)
  Essentials.customFixes[fix] = nil
  collectgarbage("collect")
end

function FixCell(cell, x, y)
  if cell.poskey == nil then
    cell.poskey = fixID
    fixID = fixID + 1
  end
  posMap[cell.poskey] = {x = x, y = y, dir = cell.rot}
  for k, v in pairs(Essentials.customFixes) do
    cell[k] = v
  end
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
  cell.nudge = function(self, dir, vars)
    return unpack{NudgeCell(self:pos().x, self:pos().y, dir, vars)}
  end
  cell.advance = function(self, dir, vars)
    local cx = self:pos().x
    local cy = self:pos().y

    if PushCell(x, y, dir, vars) then
      return unpack{PullCell(cx, cy, dir, {unpack(vars), force=(vars.force or 1)})}
    else
      return unpack{PullCell(cx, cy, dir, vars)}
    end
  end
  return cell
end
Debug("Loaded FixCell()")

local oldGetCell = GetCell

function GetCell(x,y)
	return FixCell(oldGetCell(x, y))
end
Debug("Injected into GetCell()")

Debug("> Loading cell makers...")
require("Essentials.cells")
Debug("> Loading mod loader code...")
require("Essentials.mods")
Debug("> Loading mods...")
Essentials.LoadMods()