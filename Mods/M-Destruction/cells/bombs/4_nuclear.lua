return {
  id = "MD nuclearBomb",
  name = "Nuclear Bomb",
  desc = "Like a normal bomb, but it leaves behind only uranium (except for the very close spots)",
  defaultVars = { 1 },
  properties = { "Size" },
  types = { "enemy" },
  onDeath = function(cell, x, y, vars, dir, side, force, pushtype)
    MDestruction.explode(x, y, cell.vars[1], MDestruction.bombTypes.nuclear)
  end,
  category = "Destroyers/Explosives",
  texture = "bombs/nuclear.png",
  update = function() end,
}
