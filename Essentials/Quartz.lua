if type(Quartz) == "table" then return Quartz end

Quartz = {}
Quartz.version = "0.0.1"

function table.contains(t, val)
  for k, v in pairs(t) do
    if v == val then return true end
  end
  return false
end

function V(val, ...)
  if type(val) == "function" then
    return val(...)
  else
    return val
  end
end

function D(...)
  local t = { ... }
  return function(cell)
    local rt = {}

    for i = 1, #t do
      local ind = t[i]
      rt[i] = (cell.vars[ind] or DefaultVars(cell.id)[ind])
    end

    return unpack(rt)
  end
end

Quartz.idPrefix = ""
Quartz.textureHeader = ""

function Quartz.SetIDPrefix(prefix)
  Quartz.idPrefix = prefix
end

function Quartz.SetTextureHeader(textureHeader)
  Quartz.textureHeader = textureHeader
end

local preprocessors = {}

function Quartz.reset()
  Quartz.idPrefix = ""
  Quartz.textureHeader = ""

  preprocessors = {}
end

function Quartz.AddCellLoadingPreprocessor(func)
  table.insert(preprocessors, func)
end

function Quartz.LoadFolder(path, callback)
  --assert(type(callback) == "function" or type(callback) == "nil", "Attempt to load source folder with invalid callback")
  local items = love.filesystem.getDirectoryItems(path)

  for _, item in ipairs(items) do
    if love.filesystem.getInfo(path .. "/" .. item, "directory") then
      if item:sub(1) ~= "_" then
        Quartz.LoadFolder(path .. "/" .. item, callback)
      end
    else
      if callback then
        if item:sub(- #".manual.lua") ~= ".manual.lua" or item:sub(1) == "_" then
          callback(path .. "/" .. item)
        end
      end
    end
  end
end

function Quartz.LoadAsSrcFolder(path)
  Quartz.LoadFolder(path, function(p) require(p:sub(1, #p - 4)) end)
end

function Quartz.LoadAsCellsFolder(path)
  Quartz.LoadFolder(path, function(p) require(p:sub(1, #p - 4)) end)
end

local nextsub = 118

local nextid = 65535

---@alias cellID string|number
---@alias Quartz.CellInfo {id: number|string, types?: table<string>, background?: boolean, bendPath?: function, bias?: number|function, isMarker?: function, isAcidic?: function, isTransparent?: function, isReinforced?: function, generateInto?: string, whenFlipped?: function, chunkID?: string|number, weight?: number|function, defaultVars?: table<number|string|boolean>, properties?: table<string>, push?: function, canMove?: function, nextLifeID?: cellID, nextLifeRot?: number, silent?: boolean, particles?: love.ParticleSystem, sound?: love.SoundData, onDeath?: function, onKill?: function, isDestroyer?: function, update?: function, interval?: number, updatetype?: "static"|"normal"|table, subtick?: number, whenRotated?: function, whenClicked?: function, whenSelected?: function, varsOffset?: number, overrides?: table<function|string|number|boolean>, texture: string, name: string, desc: string, rawPath?: boolean, whenRendered?: function, category: string|table<string>, savePropertiesByName?: boolean|function}

---@param cell Quartz.CellInfo
function Quartz.LoadCell(cell)
  -- Options translation
  local options = {
    id = Quartz.idPrefix .. tostring(cell.id or nextid),
  }

  nextid = nextid + 1

  local types = cell.types or {}

  if type(types) ~= "table" then
    types = { types }
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

  if isdiverter then
    options.nextCell = cell.bendPath
  end

  -- Shortcut types
  local isghost = table.contains(types, "ghost")
  local ismold = table.contains(types, "mold")

  local bias = cell.bias or 0

  if ismarker then
    options.isNonexistant = cell.isMarker or function() return true end
  end

  if isacid then
    options.isAcidic = cell.isAcidic or function(...) return true end
  end

  local isacidic = options.isAcidic

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

  --options.hasVars = ((cell.defaultVars ~= nil) or cell.hasVars)

  local weight = cell.weight or 0

  local dv = cell.defaultVars or (#(cell.properties or {}))
  if type(dv) == "number" then
    local t = {}
    for i = 1, dv do
      table.insert(t, 0)
    end
    options.defaultVars = t
  elseif type(dv) == "table" then
    options.defaultVars = dv
  end

  options.push = cell.push or function(c, dir, x, y, vars, side, force, t)
    if type(cell.canMove) == "function" then
      local cm = cell.canMove(c, dir, x, y, vars, side, force, t)

      if not cm then return false end
    end

    local mass = V(weight, c, dir, x, y, vars, side, force, t)

    if ismover or ispuller or isgrabber then
      vars.undocells[x + y * width] = vars.undocells[x + y * width] or table.copy(c)
    end

    if ismover and (t == "push") then
      if side == 2 then
        return force + V(bias, c, dir, x, y, vars, side, force, t) - mass
      end
      if side == 0 then
        c.updated = c.updated or not vars.noupdate
        return force - V(bias, c, dir, x, y, vars, side, force, t) - mass
      end
      return force
    end

    if ispuller and (t == "pull") then
      if side == 2 then
        return force + V(bias, c, dir, x, y, vars, side, force, t) - mass
      end
      if side == 0 then
        c.updated = c.updated or not vars.noupdate
        return force - V(bias, c, dir, x, y, vars, side, force, t) - mass
      end
      return force
    end

    if isgrabber and (t == "grab") then
      if side == 2 then
        return force + V(bias, c, dir, x, y, vars, side, force, t) - mass
      end
      if side == 0 then
        c.updated = c.updated or not vars.noupdate
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
          cell.onDeath(c, x, y, vars, dir, side, force, t)
        end,
      })
      return force - mass
    end

    if istrash and IsDestroyer(c, dir, x, y, vars) then
      Quartz.DoTrash(c, vars, t, {
        id = V(cell.nextLifeID, c, x, y, vars, t, force),
        rot = V(cell.nextLifeRot, c, x, y, vars, t, force),
        silent = V(cell.silent, c, x, y, vars, t, force),
        particles = V(cell.particles, c, x, y, vars, t, force),
        sound = V(cell.sound, c, x, y, vars, t, force),
        execute = function()
          if cell.onDeath then cell.onDeath(c, x, y, vars, dir, side, force, t) end
        end,
      })
      return force - mass
    end

    if isacid and isacidic then
      if isacidic(c, dir, x, y, vars) then
        if cell.onKill then
          cell.onKill(c, x, y, vars, dir, side, force, t)
        end
      end
    end

    return force - mass
  end

  if isenemy or istrash then
    if isenemy then
      options.type = "enemy"
    end
    options.isDestroyer = cell.isDestroyer or function() return true end
  end
  if cell.update then
    local int = cell.interval or 1
    options.update = function(x, y, c)
      if not c.vars['qLoc_i'] then
        c.vars['qLoc_i'] = 0
      end
      c.vars['qLoc_i'] = c.vars['qLoc_i'] + 1
      c = Quartz.FixCell(c, x, y)
      local decided = V(int, x, y, c)
      while c.vars['qLoc_i'] > decided do
        c.vars['qLoc_i'] = c.vars['qLoc_i'] - decided
        c.updated = true
        cell.update(c:pos().x, c:pos().y, c)
      end
    end
  end
  options.updatemode = cell.updatetype or "normal"
  options.updateindex = (cell.subtick or nextsub)

  if options.updateindex < nextsub then
    if options.updatemode == "static" then
      nextsub = nextsub + 1
    elseif options.updatemode == "normal" then
      nextsub = nextsub + 4
    elseif type(options.updatemode) == "table" then
      nextsub = nextsub + #(options.updatemode)
    end
  end

  options.onRotate = cell.whenRotated

  options.onClick = cell.whenClicked
  local s = cell.whenSelected

  if cell.properties ~= nil then
    local os = s

    s = function(b)
      local id = options.id
      if id ~= chosen.id then
        buttons.lastselecttab.icon = tex[id] and id or "X"
        for i = 10, 2, -1 do
          lastselects[i].onclick = lastselects[i - 1].onclick
          lastselects[i].icon = lastselects[i - 1].icon
          lastselects[i].name = lastselects[i - 1].name
          lastselects[i].desc = lastselects[i - 1].desc
        end
        lastselects[1].onclick = function() propertiesopen = 0; SetSelectedCell(id, lastselects[1]) end
        lastselects[1].icon = tex[id] and id or "X"
        if cellinfo[id] then
          lastselects[1].name = cellinfo[id].name
          lastselects[1].desc = cellinfo[id].desc
        else
          lastselects[1].name = "Placeholder B"
          lastselects[1].desc = "This ID (" .. id .. ") doesn't exist in the version of CelLua you are using."
        end
      end
      chosen.id = options.id
      if not b then return end
      MakePropertyMenu(V(cell.properties, b), b)
      chosen.data = table.copy(DefaultVars(options.id))
      if os ~= nil then os(b) end
    end

    local p = cell.whenPlaced

    cell.whenPlaced = function(c, x, y, was)
      local off = V(cell.varsOffset or 0, c, x, y, was)

      for i = 1, propertiesopen do
        if V(cell.savePropertiesByName, c, x, y, was, propertynames[i]) then
          c.vars[propertynames[i]] = chosen.data[i]
        else
          c.vars[i + off] = chosen.data[i]
        end
      end

      if p ~= nil then p(c, x, y, was) end
    end
  end

  options.onSelect = s

  if type(cell.overrides) == "table" then
    for key, value in pairs(options.overrides) do
      options[key] = value
    end
  end

  local t = Quartz.textureHeader .. (cell.texture or "default.png")
  if cell.rawPath then
    t = cell.texture or "texture/push.png"
  end

  for _, preprocessor in ipairs(preprocessors) do
    preprocessor(cell, options) -- Edit options to change stuff
  end

  local id = Quartz.LowLevelCreateCell(cell.name or "Untitled", cell.desc or "No description available", t, options) or
      cell.id

  --Event-based stuff
  if cell.whenPlaced ~= nil then
    Quartz.On("cell-place", function(c, x, y, was)
      if c.id == id then
        cell.whenPlaced(c, x, y, was)
      end
    end)
  end

  if cell.whenRendered ~= nil then
    Quartz.On("render-cell", function(c, x, y, ip)
      if c.id == id then
        cell.whenRendered(c, x, y, ip)
      end
    end)
  end

  if cell.category ~= nil then
    local cats = Quartz.FetchCategories(cell.category)

    for _, cat in ipairs(cats) do
      cat.Add(options.id)
    end
  end
end

---@alias Quartz.LowLevelOptions {id: string, convertId?: number|string, hasVars?: boolean, defaultVars?: table, type?: string, isUnbreakable?: function, isNonexistant?: function, isDestroyer?: function, isAcidic?: function, isTransparent?: function, toGenerate?: function, stopsOptimization?: function, onRotate?: function, onRotate?: function, onFlip?: function, flip?: function, push?: function, onClick?: function, onSelect?: function, nextCell?: function}

---@param name string
---@param desc string
---@param texture string
---@param options Quartz.LowLevelOptions
---@return string
function Quartz.LowLevelCreateCell(name, desc, texture, options)
  if type(options.id) ~= "string" then error("Invalid ID thrown into Quartz") end

  if Quartz.IsEssentials or Quartz.IsModchine then
    return CreateCell(name, desc, texture, options)
  end
end

function Quartz.LoadRawCellReturn(t)
  if not t then return end -- Maybe the used Quartz.LoadCell()

  if type(t[1]) == "table" then
    for _, c in ipairs(t) do
      Quartz.LoadCell(c)
    end
  else
    Quartz.LoadCell(t)
  end
end

function SplitText(text, s)
  local txts = { "" }

  for i = 1, #text do
    local c = text:sub(i, i)

    if c == s then table.insert(txts, "") else txts[#txts] = txts[#txts] .. c end
  end

  return txts
end

---@return table
---@param category string|table
function Quartz.FetchCategories(category)
  if type(category) == "string" then
    category = { category }
  end

  local trueCategories = {}

  for _, c in ipairs(category) do
    local cc = SplitText(c, ":")

    for _, ccc in ipairs(cc) do
      local cccs = SplitText(ccc, "/")

      local cat = Toolbar.GetCategory(cccs[1])
      if cccs[2] then
        table.insert(trueCategories, table.copy(cat.GetCategory(cccs[2])))
      else
        table.insert(trueCategories, cat)
      end
    end
  end

  return trueCategories
end

function Quartz.DoTrash(cell, vars, ptype, config)
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

function Quartz.DoBaseEnemy(cell, cx, cy, vars, ptype, config)
  config = config or {}

  if cell.protected or vars.lastcell.protected then return true end

  if ptype == "push" or ptype == "nudge" then
    cell.id = config.id or 0
    cell.rot = config.rot or cell.rot
    cell.lastvars = config.lastvars or cell.lastvars
    if not config.weak then
      vars.lastcell.id = 0
      if fancy then
        GetCell(cx, cy).eatencells = { table.copy(cell) }
      end
    end
    local runParticles = config.particles or enemyparticles
    if fancy then runParticles:setPosition(cx * 20 - 10, cy * 20 - 10) runParticles:emit(50) end
    if not config.silent then
      PlaySound(config.sound or sound.destroy)
    end
    if type(config.execute) == "function" then config.execute() end
  else
    vars.ended = true
  end

  return true
end

function Quartz.DoBaseTrash(cell, vars, ptype, sound, silent)
  if ptype == "push" or ptype == "nudge" then
    if fancy then
      cell.eatencells = cell.eatencells or {}
      table.insert(cell.eatencells, table.copy(vars.lastcell))
    end
    vars.lastcell.id = 0
    if not silent then
      PlaySound(sound or sound.destroy)
    end
  end

  vars.ended = true

  return true
end

DoBaseEnemy = Quartz.DoBaseEnemy
DoTrash = Quartz.DoTrash
DoBaseTrash = Quartz.DoBaseTrash

local fixID = 0

local posMap = {}

On("cell-set", function(cell, x, y, was)
  --love.window.setTitle(tostring(cell))
  Quartz.FixCell(cell, x, y)
end)

local oldRotateCell = RotateCell

function RotateCell(x, y, rot, dir, amount)
  oldRotateCell(x, y, rot, dir, amount)
  local c = GetCell(x, y)
  Quartz.FixCell(c, x, y)
end

Quartz.posmap = {}
Quartz.customFixes = {}

function Quartz.AddCustomFix(fix, func)
  Quartz.customFixes[fix] = func
end

function Quartz.RemoveCustomFix(fix, func)
  Quartz.customFixes[fix] = nil
  collectgarbage("collect")
end

function Quartz.FixCell(cell, x, y)
  if cell.poskey == nil then
    cell.poskey = fixID
    fixID = fixID + 1
  end
  posMap[cell.poskey] = { x = x, y = y, dir = cell.rot }
  for k, v in pairs(Quartz.customFixes) do
    cell[k] = v
  end
  cell.pos = function(self)
    return posMap[self.poskey]
  end
  cell.dir = function(self)
    return self:pos().dir
  end
  cell.push = function(self, dir, vars)
    return unpack { PushCell(self:pos().x, self:pos().y, dir, vars) }
  end
  cell.pull = function(self, dir, vars)
    return unpack { PullCell(self:pos().x, self:pos().y, dir, vars) }
  end
  cell.grasp = function(self, dir, vars)
    return unpack { GraspCell(self:pos().x, self:pos().y, dir, vars) }
  end
  cell.graspLeft = function(self, dir, vars)
    return unpack { LGraspCell(self:pos().x, self:pos().y, dir, vars) }
  end
  cell.graspRight = function(self, dir, vars)
    return unpack { RGraspCell(self:pos().x, self:pos().y, dir, vars) }
  end
  cell.nudge = function(self, dir, vars)
    return unpack { NudgeCell(self:pos().x, self:pos().y, dir, vars) }
  end
  cell.advance = function(self, dir, vars)
    local cx = self:pos().x
    local cy = self:pos().y

    if PushCell(x, y, dir, vars) then
      return unpack { PullCell(cx, cy, dir, { unpack(vars), force = (vars.force or 1) }) }
    else
      return unpack { PullCell(cx, cy, dir, vars) }
    end
  end
  return cell
end

local oldGetCell = GetCell

function GetCell(x, y)
  return Quartz.FixCell(oldGetCell(x, y))
end

FixCell = Quartz.FixCell
AddCustomFix = Quartz.FixCell

local events = {}

-- Uses the _G method so your IDE doesn't scream at you
---@return "Essentials"|"Modchine"|"Moddable"|"Unknown/Vanilla"
function Quartz.GetCurrentAPI()
  if _G["Essentials"] then return "Essentials" end
  if _G["Modchine"] then return "Modchine" end
  if _G["Moddable"] then return "Moddable" end

  return "Unknown/Vanilla"
end

Quartz.IsEssentials = Quartz.GetCurrentAPI() == "Essentials"
Quartz.IsModdable = Quartz.GetCurrentAPI() == "Moddable"
Quartz.IsModchine = Quartz.GetCurrentAPI() == "Modchine"
Quartz.IsVanilla = Quartz.GetCurrentAPI() == "Unknown/Vanilla"

function Quartz.On(event, callback)
  if not events[event] then events[event] = {} end

  table.insert(events[event], callback)
end

function Quartz.Trigger(event, ...)
  if not events[event] then return end

  for _, callback in ipairs(events[event]) do
    callback(...)
  end
end

function Quartz.SetupDefaultTriggers()
  if Quartz.IsEssentials or Quartz.IsModchine then
    local triggers = { "update", "render", "render-cell", "render-grid", "tick", "subtick", "set-initial", "grid-reset",
      "grid-clear", "cell-place", "cell-set", "keypressed" }

    for _, trigger in ipairs(triggers) do
      _G["On"](trigger, function(...) Quartz.Trigger(trigger, ...) end)
    end
  end
end

Quartz.SetupDefaultTriggers()

function Quartz.AddWinCondition(validator)
  if Quartz.IsEssentials or Quartz.IsModchine then
    _G["AddWinCondition"](validator)
  end
end
