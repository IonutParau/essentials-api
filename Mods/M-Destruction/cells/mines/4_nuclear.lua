return {
  id = "MD nuclearMine",
  name = "Nuclear Mine",
  desc = "Like a normal mine, but the explosion leaves behind uranium, except for the very close regions that get instantly vaporized",
  defaultVars = { 1 },
  properties = { "Size" },
  update = function(x, y, cell)
    MDestruction.DoMine(x, y, cell.vars[1], MDestruction.bombTypes.nuclear)
  end,
  category = "Destroyers/Explosives",
  texture = "bombs/nuclear.png",
}
