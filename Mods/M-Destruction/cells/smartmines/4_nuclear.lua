return {
  id = "MD nuclearSmartMine",
  name = "Nuclear SmartMine",
  desc = "A smartmine that leaves behind uranium, except for the nearby regions which are just deleted",
  defaultVars = { 1, 2 },
  properties = { "Size", "Range" },
  update = function(x, y, cell)
    MDestruction.DoSmartMine(x, y, cell.vars[2], cell.vars[1], MDestruction.bombTypes.nuclear)
  end,
  category = "Destroyers/Explosives",
  texture = "bombs/nuclear.png",
}
