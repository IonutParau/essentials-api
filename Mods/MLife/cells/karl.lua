local behaviors = {}

function behaviors.pushLeft(x, y, cell, vx, vy)
  PushCell(x - 1, y, 2, { force = 1 })
end

function behaviors.pushRight(x, y, cell, vx, vy)
  PushCell(x + 1, y, 0, { force = 1 })
end

function behaviors.pushUp(x, y, cell, vx, vy)
  PushCell(x, y - 1, 3, { force = 1 })
end

function behaviors.pushDown(x, y, cell, vx, vy)
  PushCell(x, y + 1, 1, { force = 1 })
end

function behaviors.pullLeft(x, y, cell, vx, vy)
  PushCell(x - 1, y, 2, { force = 1 })
end

function behaviors.pullRight(x, y, cell, vx, vy)
  PushCell(x + 1, y, 0, { force = 1 })
end

function behaviors.pullUp(x, y, cell, vx, vy)
  PushCell(x, y - 1, 3, { force = 1 })
end

function behaviors.pullDown(x, y, cell, vx, vy)
  PushCell(x, y + 1, 1, { force = 1 })
end

function behaviors.mirrorLR(x, y, cell, vx, vy)
  SwapCells(x - 1, y, 0, x + 1, y, 2)
end

function behaviors.mirrorTD(x, y, cell, vx, vy)
  SwapCells(x, y - 1, 1, x, y + 1, 3)
end

function behaviors.desperate(x, y, cell, vx, vy)
  if cell.vars.food < 10 then
    if not IsUnbreakable(GetCell(x + 1, y), 0, x + 1, y, { lastx = x, lasty = y, lastcell = cell }) then
      local c = GetCell(x + 1, y)
      if not cell.eatencells then cell.eatencells = {} end
      table.insert(cell.eatencells, table.copy(c))
      cell.vars.food = cell.vars.food + math.floor(love.math.random(10, 15))
    end
    if not IsUnbreakable(GetCell(x - 1, y), 2, x - 1, y, { lastx = x, lasty = y, lastcell = cell }) then
      local c = GetCell(x - 1, y)
      if not cell.eatencells then cell.eatencells = {} end
      table.insert(cell.eatencells, table.copy(c))
    end
    if not IsUnbreakable(GetCell(x, y + 1), 1, x, y + 1, { lastx = x, lasty = y, lastcell = cell }) then
      local c = GetCell(x, y + 1)
      if not cell.eatencells then cell.eatencells = {} end
      table.insert(cell.eatencells, table.copy(c))
      cell.vars.food = cell.vars.food + math.floor(love.math.random(10, 15))
    end
    if not IsUnbreakable(GetCell(x, y - 1), 3, x, y - 1, { lastx = x, lasty = y, lastcell = cell }) then
      local c = GetCell(x, y - 1)
      if not cell.eatencells then cell.eatencells = {} end
      table.insert(cell.eatencells, table.copy(c))
    end
  end
end

function AddKarlBehavior(behavior, func)
  behaviors[behavior] = func
end

function DoKarl(x, y, cell)
  if cell.vars.food == nil then
    cell.vars.food = love.math.random(50, 150)
  end
  local vx = cell.vars.vx
  local vy = cell.vars.vy

  local offs = {
    { x = -1, y = 0 },
    { x = 1, y = 0 },
    { x = 0, y = -1 },
    { x = 1, y = 1 },
    { x = -1, y = -1 },
    { x = -1, y = 1 },
    { x = 1, y = -1 },
  }

  local noffx = 0
  local noffy = 0
  local offAttempted = false

  for _, off in ipairs(offs) do
    local ox = x + off.x
    local oy = y + off.y

    local c = GetCell(ox, oy)

    if c.id == 1 then
      noffx = noffx + off.x
      noffy = noffy + off.y
      offAttempted = true
    elseif not (c.id == 0) then
      noffx = noffx - off.x
      noffy = noffy - off.y
      offAttempted = true
    end
  end

  if offAttempted then
    vx = noffx
    vy = noffy
  end

  for k, v in pairs(behaviors) do
    if cell.vars[k] then
      local nvx, nvy = v(x, y, cell, vx, vy)

      vx = vx + (nvx or 0)
      vy = vy + (nvy or 0)
    end
  end

  local ox = vx
  local oy = vy

  if ox < 0 then ox = -1 elseif ox > 0 then ox = 1 end
  if oy < 0 then oy = -1 elseif oy > 0 then oy = 1 end

  cell.vars.vx = ox
  cell.vars.vy = oy

  local nx = x + ox
  local ny = y + oy

  if nx ~= x or ny ~= y then
    local c = GetCell(nx, ny)

    if c.id == 1 then
      cell.vars.food = cell.vars.food + math.floor(love.math.random(50, 200))

      cell.vars.pregnancy = cell.vars.pregnancy + math.floor(love.math.random(0, 5))
    end

    if (c.id == 0) or (c.id == 1) then
      SetCell(nx, ny, table.copy(cell))
    else
      return
    end

    if cell.vars.food <= 0 then
      cell.eatencells = { table.copy(cells) }
      cell.id = 0
    else
      cell.vars.food = cell.vars.food - 1
    end

    if (cell.vars.pregnancy > 0) and (love.math.random(1, 1000) > 531) then
      cell.vars.pregnancy = cell.vars.pregnancy - 1
      -- We left a baebee, time to give it near-lethal doses of radiation and mutation lmao
      for k, v in pairs(behaviors) do
        -- 10% chance to mutate behavior
        if love.math.random(1, 100) < 10 then
          cell.vars[k] = (love.math.random(1, 100) <= 50) -- 50/50 it gets removed or added
        end
      end
      cell.vars.pregnancy = 0
    else
      SetCell(x, y, getempty())
    end
  end
end

return {
  id = "ML Karl",
  name = "Karl",
  desc = "An entity capable of changing behavior",
  defaultVars = { vx = 0, vy = 0, pregnancy = 0 },
  update = DoKarl,
  updatetype = "static",
  texture = "karl.png",
  category = "Miscellaneous/AI",
  whenPlaced = function(cell, x, y, was)
    cell.vars = DefaultVars("ML Karl")
  end,
}
