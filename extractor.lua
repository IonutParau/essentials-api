local lfs = love.filesystem

local function isDir(path)
	return lfs.getInfo(path, "directory")
end

local function enu(folder, saveDir, vars)
	local filesTable = lfs.getDirectoryItems(folder)
	if saveDir ~= "" and not isDir(saveDir) then lfs.createDirectory(saveDir) end

	for _,v in ipairs(filesTable) do
		local file = folder.."/"..v
		local saveFile = saveDir.."/"..v
		if saveDir == "" then saveFile = v end

		vars.debug = vars.debug .. "Extracting "..file.." to "..saveFile.."\n"

		if isDir(file) then
			if vars.name == "" then
				vars.name = string.gmatch(file, "[^/]+$")()
			end

			lfs.createDirectory(saveFile)
			enu(file, saveFile, vars)
		else
			lfs.write(saveFile, tostring(lfs.read(file)))
		end
	end
end

function extractZIP(file, dir)
	dir = dir or ""
	local temp = tostring(math.random(1000, 2000))
	if lfs.mount(file, temp) then
		local vars = { debug = "", name = "" }
		enu(temp, dir, vars)
		lfs.unmount(file)
		return vars.name
	end
end