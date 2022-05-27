return {
  id = "MD acidicBomb",
  name = "Acidic Bomb",
  desc = "A bomb that turns its exploded stuff into fire",
  defaultVars = { 1 },
  properties = { "Size" },
  types = { "enemy" },
  onDeath = function(cell, x, y, vars, dir, side, force, pushtype)
    MDestruction.explode(x, y, cell.vars[1], MDestruction.bombTypes.acidic)
  end,
  category = "Destroyers",
  subcategory = "Explosives",
  texture = "bombs/acidic.png",
  update = function() end,
}
