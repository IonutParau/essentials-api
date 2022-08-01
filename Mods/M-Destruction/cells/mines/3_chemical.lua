return {
  id = "MD chemicalMine",
  name = "Chemical Mine",
  desc = "Like a normal mine, but the explosion leaves behind huge fire",
  defaultVars = { 1 },
  properties = { "Size" },
  update = function(x, y, cell)
    MDestruction.DoMine(x, y, cell.vars[1], MDestruction.bombTypes.chemical)
  end,
  category = "Destroyers/Explosives",
  texture = "bombs/chemical.png",
}
