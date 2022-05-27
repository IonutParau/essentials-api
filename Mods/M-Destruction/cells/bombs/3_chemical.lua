return {
  id = "MD chemicalBomb",
  name = "Chemical Bomb",
  desc = "Stronger Acidic Bomb",
  defaultVars = { 1 },
  properties = { "Size" },
  types = { "enemy" },
  onDeath = function(cell, x, y, vars, dir, side, force, pushtype)
    MDestruction.explode(x, y, cell.vars[1], MDestruction.bombTypes.chemical)
  end,
  category = "Destroyers/Explosives",
  texture = "bombs/chemical.png",
  update = function() end,
}
