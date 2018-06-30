-- borrowed from Roact

local LOAD_MODULES = {
	{"lib", "Library"},
	{"modules/testez/lib", "TestEZ"},
}

package.path = package.path .. ";?/init.lua"
local lemur = require("modules.lemur")
local habitat = lemur.Habitat.new()

local Root = lemur.Instance.new("Folder")
Root.Name = "Root"

for _, module in ipairs(LOAD_MODULES) do
	local container = habitat:loadFromFs(module[1])
	container.Name = module[2]
	container.Parent = Root
end

local TestEZ = habitat:require(Root.TestEZ)
local results = TestEZ.TestBootstrap:run(Root.Library, TestEZ.Reporters.TextReporter)

if results.failureCount > 0 then
	os.exit(1)
end