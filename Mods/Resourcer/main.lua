if _G["Mod"] then
  require("Resourcer/Quartz")
  dkjson = require("Resourcer/dkjson")
else
  ---@diagnostic disable-next-line: different-requires
  require("Mods/Resourcer/Quartz")
  dkjson = require("Mods/Resourcer/dkjson")
end

local function p(path)
  if Quartz.IsModdable then return "Resourcer/" .. path else return "Mods/Resourcer/" .. path end
end

local function override(id, pack, texture)
  id = tonumber(id) or id
  local img = love.graphics.newImage(p("packs/" .. pack .. "/" .. texture))

  tex[id] = img
  texsize[id] = {
    w = img:getWidth(),
    h = img:getHeight(),
    w2 = img:getWidth() / 2,
    h2 = img:getHeight() / 2,
  }
end

---@return string|number, function
local function parseID(id)
  local rawid = tonumber(id) or id

  local onlycondition = true
  local condition = function() return onlycondition end

  if id:sub(- #"-running") == "-running" then
    onlycondition = false
    condition = function() return condition or (not paused) end
  end
  if id:sub(- #"-paused") == "-paused" then
    onlycondition = false
    condition = function() return condition or paused end
  end
  if id:sub(- #"-essentials") == "-essentials" then
    onlycondition = false
    condition = function() return condition or Quartz.IsEssentials end
  end
  if id:sub(- #"-moddable") == "-moddable" then
    onlycondition = false
    condition = function() return condition or Quartz.IsModdable end
  end
  if id:sub(- #"-modchine") == "-modchine" then
    onlycondition = false
    condition = function() return condition or Quartz.IsModchine end
  end

  return rawid, condition
end

local function animate(id, pack, textures, interval, format)
  print("Should animate")
  local sequence = {}

  for _, texture in ipairs(textures) do
    table.insert(sequence, p("packs/" .. pack .. "/" .. texture))
  end

  local trueid, condition = parseID(id)

  local animation = Quartz.NewAnimation(sequence, function()
    if format == "tick" then
      return interval
    elseif format == "second" then
      return (interval * delay)
    end
    return 1
  end, condition)

  Quartz.BindAnimation(trueid, animation)
end

local function init(self, Mod)
  local packs = love.filesystem.getDirectoryItems(p "packs")

  for _, pack in ipairs(packs) do
    if love.filesystem.getInfo(p("packs/" .. pack), "directory") then
      local json = dkjson.decode(love.filesystem.read(p("packs/" .. pack .. "/" .. pack .. ".json")), 1, nil)

      if type(json["overrides"]) == "table" then
        for id, texture in pairs(json["overrides"]) do
          override(id, pack, texture)
        end
      end
      if type(json["animations"]) == "table" then
        for id, animation in pairs(json["animations"]) do
          animate(id, pack, animation["textures"], animation["interval"] or 1, animation["format"] or "tick")
        end
      end
    end
  end
end

return Quartz.Mod("resourcer", "Resourcer", "I died and then came back. Also I can make cool texture pack", 283, init)
