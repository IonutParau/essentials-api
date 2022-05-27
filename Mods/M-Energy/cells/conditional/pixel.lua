NewTex("Mods/M-Energy/textures/conditional/pix_on.png", "pixel_on")

return {
  id = "ME pixel",
  name = "Pixel",
  desc = "White when on, black when off",
  whenRendered = function(c, x, y, ip)
    if MEnergy.GetConditional(x, y) then
      local rc = table.copy(c)
      rc.id = "pixel_on"
      DrawCell(rc, x, y, ip)
    end

  end,
  category = "Miscellaneous/MEnergy",
  texture = "conditional/pix_off.png",
}
