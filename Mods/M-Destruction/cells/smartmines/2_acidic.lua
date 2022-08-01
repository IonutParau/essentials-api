return {
  id = "MD acidicSmartMine",
  name = "Acidic SmartMine",
  desc = "A smartmine that leaves behind fire",
  defaultVars = { 1, 2 },
  properties = { "Size", "Range" },
  update = function(x, y, cell)
    MDestruction.DoSmartMine(x, y, cell.vars[2], cell.vars[1], MDestruction.bombTypes.acidic)
  end,
  category = "Destroyers/Explosives",
  texture = "bombs/acidic.png",
}
