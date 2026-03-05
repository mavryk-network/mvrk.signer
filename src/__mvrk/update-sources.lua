-- SOURCE: https://gitlab.com/mavryk-network/mavryk-protocol/-/releases
-- eli src/__mvrk/update-sources.lua https://gitlab.com/mavryk-network/mavryk-protocol/-/packages/45650499

local hjson = require "hjson"
local args = table.pack(...)
if #args < 1 then
	print("Usage: update-sources <source-url>")
	return
end

local source = args[1]

--- extract package id from url source - https://gitlab.com/mavryk-network/mavryk-protocol/-/packages/45650499
local packageId = source:match("packages/(%d+)")
if not packageId then
	print("Invalid source url")
	return
end

local response = net.download_string("https://gitlab.com/api/v4/projects/3836952/packages/" ..
	packageId .. "/package_files?per_page=100")
local files = hjson.parse(response)

local currentSources = hjson.parse(fs.read_file("src/__mvrk/sources.hjson"))
for platform, sources in pairs(currentSources) do
	local newSources = {}
	-- extract arch from linux-x86_64
	local arch = platform:match("linux%-(.*)")
	for sourceId, _ in pairs(sources) do
		-- build asset id => <arch>-mavkit-<sourceId>
		local assetIds = { [sourceId] = arch .. "-mavkit-" .. sourceId }
		for assetId, assetName in pairs(assetIds) do
			-- lookup file id
			for _, file in ipairs(files) do
				if file.file_name == assetName then
					-- update source url
					-- https://gitlab.com/mavryk-network/mavryk-protocol/-/package_files/<id>/download
					newSources[assetId] = "https://gitlab.com/mavryk-network/mavryk-protocol/-/package_files/" .. file.id .. "/download"
					break
				end
			end
		end
	end
	currentSources[platform] = newSources
end

local newContent = "// SOURCE: https://gitlab.com/mavryk-network/mavryk-protocol/-/releases"
newContent = newContent .. "\n" .. hjson.stringify(currentSources, { separator = true })

fs.write_file("src/__mvrk/sources.hjson", newContent)
