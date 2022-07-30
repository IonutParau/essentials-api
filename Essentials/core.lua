Essentials = {}

Essentials.version = "1.-1.2"

local debugMode = false

for _, flag in ipairs(arg) do
  if flag == "--essentialsDebug" then debugMode = true end
end

function Debug(...)
  if debugMode then
    print(...)
  end

  return ...
end

Debug("[ Essentials v" .. Essentials.version .. " ]")
Debug("> Loading low-level assistance...")

require("Essentials.Quartz")
Debug("Loaded Quartz API")

Debug("> Loading Quartz legacy bindings...")
require("Essentials.bindings")

Debug("> Loading mod animation systen")
require("Essentials.anim")

Debug("> Loading mod loader code...")
require("Essentials.mods")

Debug("> Loading mods...")
Essentials.LoadMods()
