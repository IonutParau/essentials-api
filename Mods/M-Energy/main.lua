if MEnergy then return MEnergy end

MEnergy = {}

MEnergy.depthLimit = 5000

function MEnergy.GetNumerical(x, y)
  return (GetCell(x, y).num or 0)
end

function MEnergy.GetConditional(x, y)
  return (GetCell(x, y).con)
end

MEnergy.listeners = {}

function MEnergy.AddListener(listener)
  table.insert(MEnergy.listeners, listener)
end

function MEnergy.EmitNumerical(x, y, amount, dir, depth)
  if depth == nil then depth = 0 end
  if depth == MEnergy.depthLimit then return end

  local cell = GetCell(x, y)

  if cell.num == nil then
    cell.num = amount
    for _, callback in ipairs(MEnergy.listeners) do
      callback("numerical", x, y, dir, amount)
    end
    if cell.id == "ME numWire" then
      depth = depth + 1 -- No stackoverflow for u
      MEnergy.EmitNumerical(x+1,y,amount,0,depth)
      MEnergy.EmitNumerical(x,y+1,amount,1,depth)
      MEnergy.EmitNumerical(x-1,y,amount,2,depth)
      MEnergy.EmitNumerical(x,y-1,amount,3,depth)
    end
  end
end

function MEnergy.EmitConditional(x, y, dir, depth)
  depth = depth or 0
  if depth == MEnergy.depthLimit then return end

  local cell = GetCell(x, y)

  if cell.con == nil then
    cell.con = true
    for _, callback in ipairs(MEnergy.listeners) do
      callback("conditional", x, y, dir)
    end
    if cell.id == "ME conWire" then
      depth = depth + 1 -- No stackoverflow for u
      MEnergy.EmitConditional(x+1,y,0,depth)
      MEnergy.EmitConditional(x,y+1,1,depth)
      MEnergy.EmitConditional(x-1,y,2,depth)
      MEnergy.EmitConditional(x,y-1,3,depth)
    end
  end
end

local menergy = CreateCategory("MEnergy", "Cells provided by the universal energy management mod", 3, {}, "Mods/M-Energy/textures/life.png")
Toolbar.GetCategory("Miscellaneous").Add(menergy)

return MEnergy