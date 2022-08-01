return {
  id = "MD normalSmartMine",
  name = "Normal SmartMine",
  desc = "A normal mine, but also has range configured seperately. It will be auto-triggered if something is outside the plast radius but inside the range",
  defaultVars = { 1, 2 },
  properties = { "Size", "Range" },
  update = function(x, y, cell)
    MDestruction.DoSmartMine(x, y, cell.vars[2], cell.vars[1], MDestruction.bombTypes.normal)
  end,
  category = "Destroyers/Explosives",
  texture = "bombs/normal.png",
}
