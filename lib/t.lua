-- t: a runtime typechecker for Roblox

-- regular lua compatibility
local typeof = typeof or type

local function primitive(typeName)
	return function(value)
		local valueType = typeof(value)
		if valueType == typeName then
			return true
		else
			return false, string.format("%s expected, got %s", typeName, valueType)
		end
	end
end

local t = {}

function t.any(value)
	if value ~= nil then
		return true
	else
		return false, "any expected, got nil"
	end
end

-- lua types
t.boolean = primitive("boolean")
t.coroutine = primitive("thread")
t.callback = primitive("function")
t.none = primitive("nil")
t.number = primitive("number")
t.string = primitive("string")
t.table = primitive("table")
t.userdata = primitive("userdata")

-- roblox types
t.Axes = primitive("Axes")
t.BrickColor = primitive("BrickColor")
t.CFrame = primitive("CFrame")
t.Color3 = primitive("Color3")
t.ColorSequence = primitive("ColorSequence")
t.ColorSequenceKeypoint = primitive("ColorSequenceKeypoint")
t.DockWidgetPluginGuiInfo = primitive("DockWidgetPluginGuiInfo")
t.Faces = primitive("Faces")
t.Instance = primitive("Instance")
t.NumberRange = primitive("NumberRange")
t.NumberSequence = primitive("NumberSequence")
t.NumberSequenceKeypoint = primitive("NumberSequenceKeypoint")
t.PathWaypoint = primitive("PathWaypoint")
t.PhysicalProperties = primitive("PhysicalProperties")
t.Random = primitive("Random")
t.Ray = primitive("Ray")
t.Rect = primitive("Rect")
t.Region3 = primitive("Region3")
t.Region3int16 = primitive("Region3int16")
t.TweenInfo = primitive("TweenInfo")
t.UDim = primitive("UDim")
t.UDim2 = primitive("UDim2")
t.Vector2 = primitive("Vector2")
t.Vector3 = primitive("Vector3")
t.Vector3int16 = primitive("Vector3int16")

-- roblox enum types
t.Enum = primitive("Enum")
t.EnumItem = primitive("EnumItem")

-- ensures value is a given value exactly
function t.exactly(exactValue)
	return function(value)
		return value == exactValue
	end
end

-- ensures value is an integer
function t.integer(value)
	local success, errMsg = t.number(value)
	if not success then
		return false, errMsg or ""
	end
	if value%1 == 0 then
		return true
	else
		return false, string.format("integer expected, got %d", value)
	end
end

-- ensures value is a number where min <= value
function t.numberMin(min)
	return function(value)
		local success, errMsg = t.number(value)
		if not success then
			return false, errMsg or ""
		end
		if value >= min then
			return true
		else
			return false, string.format("number >= %d expected, got %d", min, value)
		end
	end
end

-- ensures value is a number where value <= max
function t.numberMax(max)
	return function(value)
		local success, errMsg = t.number(value)
		if not success then
			return false, errMsg
		end
		if value <= max then
			return true
		else
			return false, string.format("number <= %d expected, got %d", max, value)
		end
	end
end

-- ensures value is a number where min < value
function t.numberMinExclusive(min)
	return function(value)
		local success, errMsg = t.number(value)
		if not success then
			return false, errMsg or ""
		end
		if min < value then
			return true
		else
			return false, string.format("number > %d expected, got %d", min, value)
		end
	end
end

-- ensures value is a number where value < max
function t.numberMaxExclusive(max)
	return function(value)
		local success, errMsg = t.number(value)
		if not success then
			return false, errMsg or ""
		end
		if value < max then
			return true
		else
			return false, string.format("number < %d expected, got %d", max, value)
		end
	end
end

-- ensures value is a number where value > 0
t.numberPositive = t.numberMinExclusive(0)

-- ensures value is a number where value < 0
t.numberNegative = t.numberMaxExclusive(0)

-- ensures value is a number where min <= value <= max
function t.numberConstrained(min, max)
	assert(t.number(min) and t.number(max))
	local minCheck = t.numberMin(min)
	local maxCheck = t.numberMax(max)
	return function(value)
		local minSuccess, minErrMsg = minCheck(value)
		if not minSuccess then
			return false, minErrMsg or ""
		end

		local maxSuccess, maxErrMsg = maxCheck(value)
		if not maxSuccess then
			return false, maxErrMsg or ""
		end

		return true
	end
end

-- ensures value is a number where min < value < max
function t.numberConstrainedExclusive(min, max)
	assert(t.number(min) and t.number(max))
	local minCheck = t.numberMinExclusive(min)
	local maxCheck = t.numberMaxExclusive(max)
	return function(value)
		local minSuccess, minErrMsg = minCheck(value)
		if not minSuccess then
			return false, minErrMsg or ""
		end

		local maxSuccess, maxErrMsg = maxCheck(value)
		if not maxSuccess then
			return false, maxErrMsg or ""
		end

		return true
	end
end

-- ensures value is either nil or passes check
function t.optional(check)
	assert(t.callback(check))
	return function(value)
		if value == nil then
			return true
		end
		local success, errMsg = check(value)
		if success then
			return true
		else
			return false, string.format("(optional) %s", errMsg or "")
		end
	end
end

-- matches given tuple against tuple type definition
function t.tuple(...)
	local checks = {...}
	return function(...)
		local args = {...}
		for i = 1, #checks do
			local success, errMsg = checks[i](args[i])
			if success == false then
				return false, string.format("Bad tuple index #%d:\n\t%s", i, errMsg or "")
			end
		end
		return true
	end
end

-- ensures all keys in given table pass check
function t.keys(check)
	assert(t.callback(check))
	return function(value)
		local tableSuccess, tableErrMsg = t.table(value)
		if tableSuccess == false then
			return false, tableErrMsg or ""
		end

		for key in pairs(value) do
			local success, errMsg = check(key)
			if success == false then
				return false, string.format("bad key %s:\n\t%s", tostring(key), errMsg or "")
			end
		end

		return true
	end
end

-- ensures all values in given table pass check
function t.values(check)
	assert(t.callback(check))
	return function(value)
		local tableSuccess, tableErrMsg = t.table(value)
		if tableSuccess == false then
			return false, tableErrMsg or ""
		end

		for key, val in pairs(value) do
			local success, errMsg = check(val)
			if success == false then
				return false, string.format("bad value for key %s:\n\t%s", tostring(key), errMsg or "")
			end
		end

		return true
	end
end

-- ensures value is a table and all keys pass keyCheck and all values pass valueCheck
function t.map(keyCheck, valueCheck)
	assert(t.callback(keyCheck), t.callback(valueCheck))
	local keyChecker = t.keys(keyCheck)
	local valueChecker = t.values(valueCheck)
	return function(value)
		local keySuccess, keyErr = keyChecker(value)
		if not keySuccess then
			return false, keyErr or ""
		end

		local valueSuccess, valueErr = valueChecker(value)
		if not valueSuccess then
			return false, valueErr or ""
		end

		return true
	end
end

-- ensures value is an array and all values of the array match check
do
	local arrayKeysCheck = t.keys(t.integer)
	function t.array(check)
		assert(t.callback(check))
		local valuesCheck = t.values(check)
		return function(value)
			local keySuccess, keyErrMsg = arrayKeysCheck(value)
			if keySuccess == false then
				return false, string.format("[array] %s", keyErrMsg or "")
			end

			-- all keys are sequential
			local arraySize = #value
			for key in pairs(value) do
				if key < 1 or key > arraySize then
					return false, string.format("[array] key %s must be sequential", tostring(key))
				end
			end

			local valueSuccess, valueErrMsg = valuesCheck(value)
			if not valueSuccess then
				return false, string.format("[array] %s", valueErrMsg or "")
			end

			return true
		end
	end
end

do
	local callbackArray = t.array(t.callback)

	-- creates a union type
	function t.union(...)
		local checks = {...}
		assert(callbackArray(checks))
		return function(value)
			for _, check in pairs(checks) do
				if check(value) then
					return true
				end
			end
			return false, "bad type for union"
		end
	end

	-- creates an intersection type
	function t.intersection(...)
		local checks = {...}
		assert(callbackArray(checks))
		return function(value)
			for _, check in pairs(checks) do
				local success, errMsg = check(value)
				if not success then
					return false, errMsg or ""
				end
			end
			return true
		end
	end
end

-- ensures value matches given interface definition
function t.interface(checkTable)
	assert(t.map(t.string, t.callback))
	return function(value)
		local tableSuccess, tableErrMsg = t.table(value)
		if tableSuccess == false then
			return false, tableErrMsg or ""
		end

		for key, check in pairs(checkTable) do
			local success, errMsg = check(value[key])
			if success == false then
				return false, string.format("[interface] bad value for %s:\n\t%s", key, errMsg or "")
			end
		end
		return true
	end
end

-- ensure value is an Instance and it's ClassName matches the given ClassName
function t.instance(className)
	assert(t.string(className))
	return function(value)
		local instanceSuccess, instanceErrMsg = t.Instance(value)
		if not instanceSuccess then
			return false, instanceErrMsg or ""
		end

		if value.ClassName ~= className then
			return false, string.format("%s expected, got %s", className, value.ClassName)
		end

		return true
	end
end

-- ensure value is an Instance and it's ClassName matches the given ClassName by an IsA comparison
function t.instanceIsA(className)
	assert(t.string(className))
	return function(value)
		local instanceSuccess, instanceErrMsg = t.Instance(value)
		if not instanceSuccess then
			return false, instanceErrMsg or ""
		end

		if not value:IsA(className) then
			return false, string.format("%s expected, got %s", className, value.ClassName)
		end

		return true
	end
end

function t.enum(enum)
	assert(t.Enum(enum))
	return function(value)
		local enumItemSuccess, enumItemErrMsg = t.EnumItem(value)
		if not enumItemSuccess then
			return false, enumItemErrMsg
		end

		if value.EnumType == enum then
			return true
		else
			return false, string.format("enum of %s expected, got enum of %s", tostring(enum), tostring(value.EnumType))
		end
	end
end

do
	local checkWrap = t.tuple(t.callback, t.callback)
	function t.wrap(callback, checkArgs)
		assert(checkWrap(callback, checkArgs))
		return function(...)
			assert(checkArgs(...))
			return callback(...)
		end
	end
end

function t.strict(check)
	return function(...)
		assert(check(...))
	end
end

return t
