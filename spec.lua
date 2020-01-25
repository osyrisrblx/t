-- polyfills
table.unpack = unpack -- luacheck: ignore

-- borrowed from Roact

local LOAD_MODULES = {
	Library = "lib",
	TestEZ = "modules/testez/src",
}

package.path = package.path .. ";?/init.lua"
local lemur = require("modules.lemur")
local habitat = lemur.Habitat.new()

local Root = lemur.Instance.new("Folder")
Root.Name = "Root"

for name, path in pairs(LOAD_MODULES) do
	local container = habitat:loadFromFs(path)
	container.Name = name
	container.Parent = Root
end

local TestEZ = habitat:require(Root.TestEZ)
local results = TestEZ.TestBootstrap:run({ Root.Library }, TestEZ.Reporters.TextReporter)

if results.failureCount > 0 then
	os.exit(1)
end
