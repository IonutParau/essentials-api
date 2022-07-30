---@alias Essentials.CellInfo Quartz.CellInfo

Essentials.AddCellLoadingPreprocessor = Quartz.AddCellLoadingPreprocessor

Quartz.AddCellLoadingPreprocessor(function(cell, options)
  Debug("Loaded " .. cell.id .. " from " .. Essentials.currentMod)
end)

Essentials.LoadFolder = Quartz.LoadFolder
Essentials.FetchCategories = Quartz.FetchCategories
Essentials.LoadAsCellsFolder = Quartz.LoadAsCellsFolder
Essentials.LoadAsSrcFolder = Quartz.LoadAsSrcFolder
Essentials.LoadCell = Quartz.LoadCell
Essentials.LoadRawCellReturn = Quartz.LoadRawCellReturn
Essentials.SetIDPrefix = Quartz.SetIDPrefix
Essentials.resetQuartzConfig = Quartz.reset

Essentials.AddCustomFix = Quartz.AddCustomFix
