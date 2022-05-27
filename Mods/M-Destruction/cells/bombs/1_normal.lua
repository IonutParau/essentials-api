return {
  id = "MD normalBomb",
  name = "Normal Bomb",
  desc = "A normal bomb",
  defaultVars = { 1 },
  properties = { "Size" },
  types = { "enemy" },
  onDeath = function(cell, x, y, vars, dir, side, force, pushtype)
    MDestruction.explode(x, y, cell.vars[1], MDestruction.bombTypes.normal)
  end,
  category = "Destroyers",
  subcategory = "Explosives",
  texture = "bombs/normal.png",
  update = function() end,
}
