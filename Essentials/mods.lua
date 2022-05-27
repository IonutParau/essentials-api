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
      if item:sub(1) ~= "_" then
        Essentials.LoadFolder(path .. "/" .. item, callback)
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

Debug("Loaded Essentials.LoadFolder()")

function FromSource(file)
  return unpack { require("Mods/" .. Essentials.currentMod .. "/src/" .. file) }
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
    local toload

    local config
    if love.filesystem.getInfo("Mods/" .. mod .. "/config.lua", "file") then
      config = require("Mods/" .. mod .. "/config")

      toload = config.overrideSources

      if config.texturePath then
        Essentials.modTexturePath = config.texturePath
      end
    end
    config = config or {}

    local srcFolder = config.srcPath or "src"
    local cellsFolder = config.cellsPath or "cells"

    require("Mods/" .. mod .. "/main")
    if not toload then
      if not config.noSrc then
        if love.filesystem.getInfo("Mods/" .. mod .. "/" .. srcFolder, "directory") then
          Essentials.LoadFolder("Mods/" .. mod .. "/" .. srcFolder, function(p) require(p:sub(1, #p - 4)) end)
        end
      end
    else
      for _, f in ipairs(toload) do
        Essentials.LoadFolder("Mods/" .. mod .. "/src/" .. f, function(p) require(p:sub(1, #p - 4)) end)
      end
    end

    if not config.noCells then
      if not cells.overrideCells then
        if love.filesystem.getInfo("Mods/" .. mod .. "/" .. cellsFolder, "directory") then
          Essentials.LoadFolder("Mods/" .. mod .. "/" .. cellsFolder, function(p) Essentials.LoadRawCellReturn(require(p:sub(1, #p - 4))) end)
        end
      else
        for _, v in ipairs(cells.overrideCells) do
          if love.filesystem.getInfo("Mods/" .. mod .. "/" .. cellsFolder .. "/" .. v, "directory") then
            Essentials.LoadFolder("Mods/" .. mod .. "/" .. cellsFolder .. "/" .. v, function(p) Essentials.LoadRawCellReturn(require(p:sub(1, #p - 4))) end)
          else
            require("Mods/" .. mod .. "/" .. cellsFolder .. "/" .. v:sub(1, #v - 4))
          end
        end
      end
    end
  end

  Essentials.modTexturePath = nil
  Essentials.idPrefix = ""
  Essentials.currentMod = nil
end

Debug("Loaded Essentials.LoadMod()")

function Depend(...)
  local t = { ... }

  for _, mod in ipairs(t) do
    if loaded[mod] ~= true then
      Essentials.LoadMod(mod)
    end
  end
end

Debug("Loaded Depend()")
