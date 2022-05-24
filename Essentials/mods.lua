local loaded = {}

Essentials.modTexturePath = nil

Essentials.currentMod = nil

function Essentials.LoadMods()
  local mods = love.filesystem.getDirectoryItems("Mods")
	for _, mod in ipairs(mods) do
		if love.filesystem.getInfo("Mods/" .. mod, "directory") then
			Essentials.LoadMod(mod)
		end
	end
end
Debug("Loaded Essentials.LoadMods()")

function Essentials.LoadFolder(path, callback)
  --assert(type(callback) == "function" or type(callback) == "nil", "Attempt to load source folder with invalid callback")
  local items = love.filesystem.getDirectoryItems(path)

  for _, item in ipairs(items) do
    if love.filesystem.getInfo(path .. "/" .. item, "directory") then
      Essentials.LoadFolder(path .. "/" .. item, callback)
    else
      if callback then
        if item:sub(-#".manual.lua") ~= ".manual.lua" or item:sub(1) == "_" then
          callback(path .. "/" .. item)
        end
      end
    end
  end
end
Debug("Loaded Essentials.LoadFolder()")

function FromSource(file)
  return unpack{require("Mods/" .. Essentials.currentMod .. "/src/" .. file)}
end
Debug("Loaded Essentials.FromSource()")

function Essentials.LoadMod(mod)
  if loaded[mod] then
    Debug("Attempt to load duplicate mod: " .. mod)
    return
  end

  Essentials.currentMod = mod

  Essentials.modTexturePath = "Mods/" .. mod .. "/textures/"
  
  loaded[mod] = true
  Debug("Loaded " .. mod)
  
  if love.filesystem.getInfo("Mods/" .. mod, "directory") then
    require("Mods/" .. mod .. "/main")

    if love.filesystem.getInfo("Mods/" .. mod .. "/src", "directory") then
      Essentials.LoadFolder("Mods/" .. mod .. "/src", function(p) require(p:sub(1, #p-4)) end)
    end

    if love.filesystem.getInfo("Mods/" .. mod .. "/cells", "directory") then
      Essentials.LoadFolder("Mods/" .. mod .. "/cells", function(p) Essentials.LoadRawCellReturn(require(p:sub(1, #p-4))) end)
    end
  end

  Essentials.modTexturePath = nil
  Essentials.idPrefix = ""
  Essentials.currentMod = nil
end
Debug("Loaded Essentials.LoadMod()")

function Depend(...)
  local t = {...}

  for _, mod in ipairs(t) do
    if loaded[mod] ~= true then
      Essentials.LoadMod(mod)
    end
  end
end
Debug("Loaded Depend()")