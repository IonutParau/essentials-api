OnCellPlace(function(cell, x, y, was)
  if cell.id == "ME numConstantGen" then
    cell.vars[1] = chosen.data[1]
  end
end)

OnRenderCell(function(cell, x, y, ip)
  if cell.id == "ME numConstantGen" then
    local cx, cy, crot
    local lerp = itime / delay
    if ip then
      cx, cy, crot = math.floor(math.graphiclerp(cell.lastvars[1], x, lerp) * cam.zoom - cam.x + cam.zoom * .5 + 400 * winxm), math.floor(math.graphiclerp(cell.lastvars[2], y, lerp) * cam.zoom - cam.y + cam.zoom * .5 + 300 * winym), math.graphiclerp(cell.lastvars[3], cell.lastvars[3] + ((cell.rot - cell.lastvars[3] + 2) % 4 - 2), lerp) * math.pi * .5
    else
      cx, cy, crot = math.floor(x * cam.zoom - cam.x + cam.zoom * .5 + 400 * winxm), math.floor(y * cam.zoom - cam.y + cam.zoom * .5 + 300 * winym), cell.rot * math.pi * .5
    end
    local r, g, b, a = love.graphics.getColor()
    local n = cell.vars[1]
    love.graphics.printf(tostring(n), cx - .22 * cam.zoom, cy - .1 * cam.zoom, 20, "center", 0, cam.zoom / 40, cam.zoom / 40)
    love.graphics.setColor(r, g, b, a)
    love.graphics.printf(tostring(n), cx - .23 * cam.zoom, cy - .11 * cam.zoom, 20, "center", 0, cam.zoom / 40, cam.zoom / 40)
  elseif cell.id == "ME numVoltMeter" then
    local cx, cy, crot
    local lerp = itime / delay
    if ip then
      cx, cy, crot = math.floor(math.graphiclerp(cell.lastvars[1], x, lerp) * cam.zoom - cam.x + cam.zoom * .5 + 400 * winxm), math.floor(math.graphiclerp(cell.lastvars[2], y, lerp) * cam.zoom - cam.y + cam.zoom * .5 + 300 * winym), math.graphiclerp(cell.lastvars[3], cell.lastvars[3] + ((cell.rot - cell.lastvars[3] + 2) % 4 - 2), lerp) * math.pi * .5
    else
      cx, cy, crot = math.floor(x * cam.zoom - cam.x + cam.zoom * .5 + 400 * winxm), math.floor(y * cam.zoom - cam.y + cam.zoom * .5 + 300 * winym), cell.rot * math.pi * .5
    end
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(0, 0, 0, 1)
    local n = MEnergy.GetNumerical(x, y)
    love.graphics.printf(tostring(n), cx - .22 * cam.zoom, cy - .1 * cam.zoom, 20, "center", 0, cam.zoom / 40, cam.zoom / 40)
    love.graphics.setColor(r, g, b, a)
    love.graphics.printf(tostring(n), cx - .23 * cam.zoom, cy - .11 * cam.zoom, 20, "center", 0, cam.zoom / 40, cam.zoom / 40)
  end
end)

return {
  {
    id = "ME numConstantGen",
    texture = "numerical/generator.png",
    name = "Numerical Generator",
    desc = "Creates numerical signals in all 4 directions",
    category = "Miscellaneous/MEnergy",
    whenSelected = function(b)
      chosen.id = "ME numConstantGen"
      MakePropertyMenu({
        "Amount",
      }, b)
    end,
    defaultVars = 1,
    update = function(x, y, cell)
      MEnergy.EmitNumerical(x + 1, y, cell.vars[1], 0)
      MEnergy.EmitNumerical(x, y + 1, cell.vars[1], 1)
      MEnergy.EmitNumerical(x - 1, y, cell.vars[1], 2)
      MEnergy.EmitNumerical(x, y - 1, cell.vars[1], 3)
    end,
    updatetype = "static",
  },
  {
    id = "ME numWire",
    texture = "numerical/wire.png",
    name = "Numerical Wire",
    desc = "Spreads numerical signals in all 4 directions",
    category = "Miscellaneous/MEnergy",
    subcategory = "MEnergy",
  },
  {
    id = "ME numVoltMeter",
    texture = "numerical/voltimeter.png",
    name = "Numerical VoltMeter",
    desc = "Continously displays its Numerical value",
    category = "Miscellaneous/MEnergy",
    subcategory = "MEnergy",
  },
}
