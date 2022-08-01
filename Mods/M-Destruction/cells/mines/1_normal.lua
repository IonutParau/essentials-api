return {
  id = "MD normalMine",
  name = "Normal Mine",
  desc = "A normal mine",
  defaultVars = { 1 },
  properties = { "Size" },
  update = function(x, y, cell)
    MDestruction.DoMine(x, y, cell.vars[1], MDestruction.bombTypes.normal)
  end,
  category = "Destroyers/Explosives",
  texture = "bombs/normal.png",
}
