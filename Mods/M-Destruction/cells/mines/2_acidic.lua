return {
  id = "MD acidicMine",
  name = "Acidic Mine",
  desc = "Like a normal mine, but the explosion leaves behind normal fire",
  defaultVars = { 1 },
  properties = { "Size" },
  update = function(x, y, cell)
    MDestruction.DoMine(x, y, cell.vars[1], MDestruction.bombTypes.acidic)
  end,
  category = "Destroyers/Explosives",
  texture = "bombs/acidic.png",
}
