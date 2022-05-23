function table.contains(t, val)
  for k, v in pairs(t) do
    if v == val then return true end
  end
  return false
end
print("Loaded table.contains()")

function V(val, ...)
  if type(val) == "function" then
    return val(...)
  else
    return val
  end
end

print("Loaded V()")

Essentials.idPrefix = ""

function Essentials.SetIDPrefix(prefix)
  Essentials.idPrefix = prefix
end
print("Loaded Essentials.SetIDPrefix()")

local preprocessors = {}

function Essentials.AddCellLoadingPreprocessor(func)
  table.insert(preprocessors, func)
end
print("Loaded Essentials.AddCellLoadingPreprocessor()")

local nextsub = 118

function Essentials.LoadCell(cell)
  -- Options translation
  local options = {
    id = Essentials.idPrefix .. tostring(cell.id),
  }

  local types = cell.types or {}

  if type(types) ~= "table" then
    types = {types}
  end

  if cell.background then
    options.type = "background"
  end

  local ismover = table.contains(types, "mover")
  local ispuller = table.contains(types, "puller")
  local isgrabber = table.contains(types, "grabber")
  local istrash = table.contains(types, "trash")
  local isenemy = table.contains(types, "enemy")
  local istransparent = table.contains(types, "transparent")
  local isacid = table.contains(types, "acid")
  local ismarker = table.contains(types, "marker")
  local isunbreakable = table.contains(types, "reinforced")
  local isdiverter = table.contains(types, "diverter")
  
  -- Shortcut types
  local isghost = table.contains(types, "ghost")
  local ismold = table.contains(types, "mold")

  local bias = cell.bias or 0

  if ismarker then
    options.isNonexistant = cell.isMarker or function() return true end
  end

  if isacid then
    options.isAcidic = cell.isAcidic or function() return true end
  end

  if istransparent then
    options.isTransparent = cell.isTransparent or function() return true end
  end

  if isunbreakable then
    options.isUnbreakable = cell.isReinforced or function() return true end
  end

  if type(cell.generateInto) ~= "function" then
    options.toGenerate = function(c, dir, x, y, side)
      if isghost then
        return nil
      end
      if ismold then
        return getempty()
      end
      c.id = (cell.generateInto or c.id)
      return c
    end
  else
    options.toGenerate = cell.generateInto
  end

  options.flipCell = cell.whenFlipped

  options.convertID = cell.chunkID

  options.hasVars = ((cell.defaultVars ~= nil) or cell.hasVars)

  local weight = cell.weight or 0

  local dv = cell.defaultVars
  if type(dv) == "number" then
    local t = {}
    for i=1,dv do
      table.insert(t, 0)
    end
    options.defaultVars = t
  elseif type(dv) == "table" then
    options.defaultVars = dv
  end

  options.push = cell.push or function(c, dir, x, y, vars, side, force, t)
    local mass = V(weight, c, dir, x, y, vars, side, force, t)
    
    if ismover or ispuller or isgrabber then
      vars.undocells[x+y*width] = vars.undocells[x+y*width] or table.copy(cell)
    end
    
    if ismover and (t == "push") then
      if side == 2 then
        return force + V(bias, c, dir, x, y, vars, side, force, t) - mass
      end
      if side == 0 then
        cell.updated = cell.updated or not vars.noupdate
        return force - V(bias, c, dir, x, y, vars, side, force, t) - mass
      end
      return force
    end

    if ispuller and (t == "pull") then
      if side == 2 then
        return force + V(bias, c, dir, x, y, vars, side, force, t) - mass
      end
      if side == 0 then
        cell.updated = cell.updated or not vars.noupdate
        return force - V(bias, c, dir, x, y, vars, side, force, t) - mass
      end
      return force
    end

    if isgrabber and (t == "grab") then
      if side == 2 then
        return force + V(bias, c, dir, x, y, vars, side, force, t) - mass
      end
      if side == 0 then
        cell.updated = cell.updated or not vars.noupdate
        return force - V(bias, c, dir, x, y, vars, side, force, t) - mass
      end
      return force
    end

    if isenemy and IsDestroyer(c, dir, x, y, vars) then
      DoBaseEnemy(c, x, y, vars, t, {
        id = V(cell.nextLifeID, c, x, y, vars, t, force),
        rot = V(cell.nextLifeRot, c, x, y, vars, t, force),
        silent = V(cell.silent, c, x, y, vars, t, force),
        particles = V(cell.particles, c, x, y, vars, t, force),
        sound = V(cell.sound, c, x, y, vars, t, force),
        execute = function()
          cell.onDeath(c, x, y, vars, dir, side, force)  
        end,
      })
      return force - mass
    end

    if istrash and IsDestroyer(c, dir, x, y, vars) then
      DoTrash(c, vars, t, {
        id = V(cell.nextLifeID, c, x, y, vars, t, force),
        rot = V(cell.nextLifeRot, c, x, y, vars, t, force),
        silent = V(cell.silent, c, x, y, vars, t, force),
        particles = V(cell.particles, c, x, y, vars, t, force),
        sound = V(cell.sound, c, x, y, vars, t, force),
        execute = function()
          cell.onDeath(c, x, y, vars, dir, side, force)  
        end,
      })
      return force - mass
    end

    return force - mass
  end

  if isenemy or istrash then
    options.isDestroyer = cell.isDestroyer or function() return true end
  end

  options.update = function(x, y, c)
    cell.update(x, y, FixCell(c, x, y))
  end
  options.updatemode = cell.updatetype or "normal"
  options.updateindex = (cell.subtick or nextsub)

  if options.updatemode == "static" then
    nextsub = nextsub + 1
  elseif options.updatemode == "normal" then
    nextsub = nextsub + 4
  elseif type(options.updatemode) == "table" then
    nextsub = nextsub + #(options.updatemode)
  end

  options.onRotate = cell.whenRotated

  options.onClick = cell.whenClicked
  local s = cell.whenSelected

  if cell.properties ~= nil then
    local os = s

    s = function(b)
      chosen.id = options.id
      MakePropertyMenu(V(cell.properties, b), b)
      if os ~= nil then os(b) end
    end

    local p = cell.whenPlaced

    cell.whenPlaced = function(c, x, y, vars)
      local off = V(cell.varsOffset or 0, c, x, y, vars)

      for i=1,propertiesopen do
        c.vars[i + off] = chosen.data[i]
      end

      if p ~= nil then p(c, x, y, vars) end
    end
  end

  options.onSelect = s

  if isdiverter then
    options.nextCell = cell.bendPath
  end

  if type(cell.overrides) == "table" then
    for key, value in pairs(options.overrides) do
      options[key] = value
    end
  end

  local t = Essentials.modTexturePath .. (cell.texture or "default.png")
  if cell.rawPath then
    t = cell.texture or "texture/push.png"
  end

  for _, preprocessor in ipairs(preprocessors) do
    preprocessor(cell, options) -- Edit options to change stuff
  end

  local id = CreateCell(cell.name or "Untitled", cell.desc or "No description available", t, options)

  --Event-based stuff
  if cell.whenPlaced ~= nil then
    OnCellPlace(function(c, x, y, was)
      if c.id == cell.id then
        cell.whenPlaced(c, x, y, was)
      end
    end)
  end

  if cell.whenRendered ~= nil then
    OnRenderCell(function(c, x, y, ip)
      if c.id == cell.id then
        cell.whenRendered(c, x, y, ip)
      end
    end)
  end

  -- Category insertion
  local cat = Toolbar.GetCategory(cell.category)
  if cell.subcategory then
    local sub = cat.GetCategory(cell.subcategory)
    sub.Add(id, cell.categoryIndex)
  else
    cat.Add(id, cell.categoryIndex)
  end
end
print("Loaded Essentials.LoadCell()")

function Essentials.LoadRawCellReturn(t)
  if not t then return end -- Maybe the used Essentials.LoadCell()
  
  if type(t[1]) == "table" then
    for _, c in ipairs(t) do
      Essentials.LoadCell(c)
    end
  else
    Essentials.LoadCell(t)
  end
end
print("Loaded Essentials.LoadRawCellReturn()")

function DoTrash(cell, vars, ptype, config)
	if ptype == "push" or ptype == "nudge" then
	  if fancy then
			cell.eatencells = cell.eatencells or {}
			table.insert(cell.eatencells, table.copy(vars.lastcell))
		end
		vars.lastcell.id = 0
		if not config.silent then
			PlaySound(config.sound or sound.destroy)
		end
    if config.execute then config.execute() end
	end

	vars.ended = true

	return true
end
print("Loaded DoTrash()")