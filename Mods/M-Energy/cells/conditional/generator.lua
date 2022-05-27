return {
  id = "ME conGenenerator",
  name = "Conditional Generator",
  desc = "Generates conditional signals in all 4 directions",
  category = "Miscellaneous/MEnergy",
  update = function(x, y, c)
    MEnergy.EmitConditional(x + 1, y, 0)
    MEnergy.EmitConditional(x - 1, y, 2)
    MEnergy.EmitConditional(x, y + 1, 1)
    MEnergy.EmitConditional(x, y - 1, 3)
  end,
  texture = "conditional/generator.png",
}
