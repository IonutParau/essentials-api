return {
  id = "MD chemicalSmartMine",
  name = "Chemical SmartMine",
  desc = "A smartmine that leaves behind huge fire",
  defaultVars = { 1, 2 },
  properties = { "Size", "Range" },
  update = function(x, y, cell)
    MDestruction.DoSmartMine(x, y, cell.vars[2], cell.vars[1], MDestruction.bombTypes.acidic)
  end,
  category = "Destroyers/Explosives",
  texture = "bombs/chemical.png",
}
