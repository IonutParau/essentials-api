local assist = {
  ignore = 0,
  rotateCW = 1,
  rotateCCW = 2,
  flip = 3,
}

local max = 0
for _, v in pairs(assist) do
  if v > max then max = v end
end

local fields = {
  "front_food",
  "left_food",
  "right_food",
  "back_food",
  "front_danger",
  "left_danger",
  "right_danger",
  "back_danger",
  "front_unknown",
  "left_unknown",
  "right_unknown",
  "back_unknown",
}

local function DoCellMovement(x, y, cell)
  local fx, fy = GetFrontPos(x, y, cell:dir(), 1)
  local c = GetCell(fx, fy)
  if ConvertId(c.id) == 123 then
    if not cell.eatencells then cell.eatencells = {} end
    table.insert(cell.eatencells, table.copy(c))
    SetCell(fx, fy, getempty())
    if love.math.random() < 0.9 then
      local bx, by = GetFrontPos(x, y, cell.rot, -1)
      local spore = getempty()
      spore.id = "ML cellSpore"
      spore.vars = table.copy(cell.vars)
      spore.lastvars = { bx, by, 0 }
      PushCell(bx, by, (cell.rot + 2) % 4, { replacecell = spore, force = 60 })
    end
    cell:push(cell.rot)
  else
    cell:push(cell.rot)
  end
end

return {
  id = "ML cell",
  name = "Cell",
  desc = "Can evolve by changing behavior",
  texture = "textures/life.png",
  rawPath = true,
  types = { "reinforced", "mover" },
  bias = 1,
  isReinforced = function(cell, dir, x, y, vars, side)
    if vars.forcetype == "infect" then
      return true
    end
  end,
  update = function(x, y, cell)
    if not cell.vars then cell.vars = {} end
    for _, field in ipairs(fields) do
      if not cell.vars[field] then
        cell.vars[field] = math.floor(love.math.random(0, max + 1))
      end
    end

    local fx, fy = GetFrontPos(x, y, cell:dir(), 1)
    local bx, by = GetFrontPos(x, y, cell:dir(), -1)
    local lx, ly = GetFrontPos(x, y, (cell:dir() + 1) % 4, -1)
    local rx, ry = GetFrontPos(x, y, (cell:dir() + 1) % 4, 1)

    local f = GetCell(fx, fy)
    local b = GetCell(bx, by)
    local l = GetCell(lx, ly)
    local r = GetCell(rx, ry)

    if ConvertId(f.id) == 123 and cell.vars["front_food"] ~= assist.ignore then
      local a = fields["front_food"]

      if a == assist.rotateCW then
        RotateCell(x, y, cell:dir(), 1)
      end
      if a == assist.rotateCCW then
        RotateCell(x, y, cell:dir(), -1)
      end
      if a == assist.flip then
        RotateCell(x, y, cell:dir(), 2)
      end
    elseif ConvertId(b.id) == 123 and cell.vars["back_food"] ~= assist.ignore then
      local a = fields["back_food"]

      if a == assist.rotateCW then
        RotateCell(x, y, cell:dir(), 1)
      end
      if a == assist.rotateCCW then
        RotateCell(x, y, cell:dir(), -1)
      end
      if a == assist.flip then
        RotateCell(x, y, cell:dir(), 2)
      end
    elseif ConvertId(l.id) == 123 and cell.vars["left_food"] ~= assist.ignore then
      local a = fields["left_food"]

      if a == assist.rotateCW then
        RotateCell(x, y, cell:dir(), 1)
      end
      if a == assist.rotateCCW then
        RotateCell(x, y, cell:dir(), -1)
      end
      if a == assist.flip then
        RotateCell(x, y, cell:dir(), 2)
      end
    elseif ConvertId(r.id) == 123 and cell.vars["right_food"] ~= assist.ignore then
      local a = fields["right_food"]

      if a == assist.rotateCW then
        RotateCell(x, y, cell:dir(), 1)
      end
      if a == assist.rotateCCW then
        RotateCell(x, y, cell:dir(), -1)
      end
      if a == assist.flip then
        RotateCell(x, y, cell:dir(), 2)
      end
    elseif IsDestroyer(f, cell:dir(), fx, fy, { forcetype = "infect" }) then
      local a = fields["front_danger"]

      if a == assist.rotateCW then
        RotateCell(x, y, cell:dir(), 1)
      end
      if a == assist.rotateCCW then
        RotateCell(x, y, cell:dir(), -1)
      end
      if a == assist.flip then
        RotateCell(x, y, cell:dir(), 2)
      end
    elseif IsDestroyer(b, (cell:dir() + 2) % 4, bx, by, { forcetype = "infect" }) then
      local a = fields["back_danger"]

      if a == assist.rotateCW then
        RotateCell(x, y, cell:dir(), 1)
      end
      if a == assist.rotateCCW then
        RotateCell(x, y, cell:dir(), -1)
      end
      if a == assist.flip then
        RotateCell(x, y, cell:dir(), 2)
      end
    elseif IsDestroyer(l, (cell:dir() + 2) % 4, lx, ly, { forcetype = "infect" }) then
      local a = fields["left_danger"]

      if a == assist.rotateCW then
        RotateCell(x, y, cell:dir(), 1)
      end
      if a == assist.rotateCCW then
        RotateCell(x, y, cell:dir(), -1)
      end
      if a == assist.flip then
        RotateCell(x, y, cell:dir(), 2)
      end
    elseif IsDestroyer(r, (cell:dir() + 2) % 4, rx, ry, { forcetype = "infect" }) then
      local a = fields["right_danger"]

      if a == assist.rotateCW then
        RotateCell(x, y, cell:dir(), 1)
      end
      if a == assist.rotateCCW then
        RotateCell(x, y, cell:dir(), -1)
      end
      if a == assist.flip then
        RotateCell(x, y, cell:dir(), 2)
      end
    end

    DoCellMovement(x, y, cell)
  end,
  category = { "Miscellaneous/AI" },
}
