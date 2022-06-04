return {
  id = "ML cellSpore",
  name = "Cell Spore",
  desc = "How did you get here?",
  texture = "textures/life.png",
  rawPath = true,
  update = function(x, y, cell)
    local dir = love.math.random(0, 4)
    local fx, fy = GetFrontPos(x, y, dir, 1)

    local c = GetCell(fx, fy)

    if IsNonexistant(c, dir, fx, fy) then
      cell:push(dir, { force = 1 })
    elseif c.id == "ML cell" then
      cell.id = "ML cell"
      -- Mutate the genes so on average 50% are from the father and 50% from the mother.
      for k, v in pairs(c.vars or {}) do
        if love.math.random() < 0.5 then
          cell.vars[k] = v
        end
      end
      cell.rot = dir
    end
  end,
}
