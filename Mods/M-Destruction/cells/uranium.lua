local function infect(x, y, output, intensity)
  if love.math.random(1, 1000) < intensity then
    local c = GetCell(x, y)
    if c.id ~= 0 and c.id ~= output.id then
      SetCell(x, y, table.copy(output))
    end
  end
end

return {
  id = "MD uranium",
  defaultVars = { 500 },
  properties = { "Intensity" },
  name = "Uranium",
  desc = "A radioactive cell. Spreads based off of given intensity.",
  category = "Miscellaneous/Infectious",
  update = function(x, y, cell)
    local i = cell.vars[1] or 500

    infect(x + 1, y, cell, i)
    infect(x - 1, y, cell, i)
    infect(x, y + 1, cell, i)
    infect(x, y - 1, cell, i)
  end,
  texture = "uranium.png",
}
