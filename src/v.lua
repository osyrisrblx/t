-- v: a runtime typechecker for Roblox
-- Osyris

-- regular lua compatibility
local typeof = typeof or type

local function primitive(typeName)
	return function(value)
		if typeof(value) == typeName then
			return true
		else
			return false, string.format("%s expected, got %s", typeName, typeof(value))
		end
	end
end

local v = {}

function v.any(value)
	if value ~= nil then
		return true
	else
		return "any expected, got nil"
	end
end

-- lua types
v.boolean = primitive("boolean")
v.coroutine = primitive("coroutine")
v.callback = primitive("function")
v.none = primitive("nil")
v.number = primitive("number")
v.string = primitive("string")
v.table = primitive("table")

-- roblox types
v.Axes = primitive("Axes")
v.BrickColor = primitive("BrickColor")
v.CFrame = primitive("CFrame")
v.Color3 = primitive("Color3")
v.ColorSequence = primitive("ColorSequence")
v.ColorSequenceKeypoint = primitive("ColorSequenceKeypoint")
v.DockWidgetPluginGuiInfo = primitive("DockWidgetPluginGuiInfo")
v.Faces = primitive("Faces")
v.Instance = primitive("Instance")
v.NumberRange = primitive("NumberRange")
v.NumberSequence = primitive("NumberSequence")
v.NumberSequenceKeypoint = primitive("NumberSequenceKeypoint")
v.PathWaypoint = primitive("PathWaypoint")
v.PhysicalProperties = primitive("PhysicalProperties")
v.Random = primitive("Random")
v.Ray = primitive("Ray")
v.Rect = primitive("Rect")
v.Region3 = primitive("Region3")
v.Region3int16 = primitive("Region3int16")
v.TweenInfo = primitive("TweenInfo")
v.UDim = primitive("UDim")
v.UDim2 = primitive("UDim2")
v.Vector2 = primitive("Vector2")
v.Vector3 = primitive("Vector3")
v.Vector3int16 = primitive("Vector3int16")

-- ensures value is an integer
function v.integer(value)
	local success, errMsg = v.number(value)
	if not success then
		return false, errMsg
	end
	if value%1 == 0 then
		return true
	else
		return false, "integer expected, got non-integer"
	end
end

-- ensures value is a number where min <= value
function v.numberMin(min)
	return function(value)
		local success, errMsg = v.number(value)
		if not success then
			return false, errMsg
		end
		if value >= min then
			return true
		else
			return false, string.format("number >= %d expected", min)
		end
	end
end

-- ensures value is a number where value <= max
function v.numberMax(max)
	return function(value)
		local success, errMsg = v.number(value)
		if not success then
			return false, errMsg
		end
		if value <= max then
			return true
		else
			return false, string.format("number <= %d expected", max)
		end
	end
end

-- ensures value is a number where min < value
function v.numberMinExclusive(min)
	return function(value)
		local success, errMsg = v.number(value)
		if not success then
			return false, errMsg
		end
		if min < value then
			return true
		else
			return false, string.format("number > %d expected", min)
		end
	end
end

-- ensures value is a number where value < max
function v.numberMaxExclusive(max)
	return function(value)
		local success, errMsg = v.number(value)
		if not success then
			return false, errMsg
		end
		if value < max then
			return true
		else
			return false, string.format("number < %d expected", max)
		end
	end
end

-- ensures value is a number where value > 0
v.numberPositive = v.numberMinExclusive(0)

-- ensures value is a number where value < 0
v.numberNegative = v.numberMaxExclusive(0)

-- ensures value is a number where min <= value <= max
function v.numberConstrained(min, max)
	assert(v.number(min) and v.number(max))
	local minCheck = v.numberMin(min)
	local maxCheck = v.numberMax(max)
	return function(value)
		local minSuccess, minErrMsg = minCheck(value)
		if not minSuccess then
			return false, minErrMsg
		end

		local maxSuccess, maxErrMsg = maxCheck(value)
		if not maxSuccess then
			return false, maxErrMsg
		end

		return true
	end
end

-- ensures value is a number where min < value < max
function v.numberConstrainedExclusive(min, max)
	assert(v.number(min) and v.number(max))
	local minCheck = v.numberMinExclusive(min)
	local maxCheck = v.numberMaxExclusive(max)
	return function(value)
		local minSuccess, minErrMsg = minCheck(value)
		if not minSuccess then
			return false, minErrMsg
		end

		local maxSuccess, maxErrMsg = maxCheck(value)
		if not maxSuccess then
			return false, maxErrMsg
		end

		return true
	end
end

-- ensures value is either nil or passes check
function v.optional(check)
	assert(v.callback(check))
	return function(value)
		if value == nil then
			return true
		end
		local success, errMsg = check(value)
		if success then
			return true
		else
			return false, string.format("(optional) %s", errMsg)
		end
	end
end

-- matches given tuple against tuple type definition
function v.tuple(...)
	local checks = {...}
	return function(...)
		local args = {...}
		for i = 1, #checks do
			local success, errMsg = checks[i](args[i])
			if success == false then
				return false, string.format("Bad tuple index #%d: %s", i, errMsg)
			end
		end
		return true
	end
end

-- ensures all keys in given table pass check
function v.strictKeys(check)
	assert(v.callback(check))
	return function(value)
		local tableSuccess, tableErrMsg = v.table(value)
		if tableSuccess == false then
			return false, tableErrMsg
		end

		for key in pairs(value) do
			local success, errMsg = check(key)
			if success == false then
				return false, string.format("table bad key %s: %s", key, errMsg)
			end
		end

		return true
	end
end

-- ensures all values in given table pass check
function v.strictValues(check)
	assert(v.callback(check))
	return function(value)
		local tableSuccess, tableErrMsg = v.table(value)
		if tableSuccess == false then
			return false, tableErrMsg
		end

		for _, val in pairs(value) do
			local success, errMsg = check(val)
			if success == false then
				return false, string.format("table bad value, got %s: %s", typeof(value), errMsg)
			end
		end

		return true
	end
end

-- ensures value is a table and all keys pass keyCheck and all values pass valueCheck
function v.map(keyCheck, valueCheck)
	assert(v.callback(keyCheck), v.callback(valueCheck))
	local keyChecker = v.strictKeys(keyCheck)
	local valueChecker = v.strictValues(valueCheck)
	return function(value)
		local keySuccess, keyErr = keyChecker(value)
		if not keySuccess then
			return false, keyErr
		end

		local valueSuccess, valueErr = valueChecker(value)
		if not valueSuccess then
			return false, valueErr
		end

		return true
	end
end


-- ensures value is an array
do
	local arrayKeysCheck = v.strictKeys(v.integer)
	function v.array(value)
		local keySuccess, keyErrMsg = arrayKeysCheck(value)
		if keySuccess == false then
			return false, keyErrMsg
		end

		-- all keys are sequential
		local expected = 1
		for i = 1, #value do
			if i == expected then
				if value[i] ~= nil then
					expected = expected + 1
				end
			else
				return false, "Bad array, keys must be sequential"
			end
		end

		return true
	end
end

-- ensures value is an array and all values of the array match check
function v.strictArray(check)
	assert(v.callback(check))
	local strictValuesCheck = v.strictValues(check)
	return function(value)
		local arraySuccess, arrayErrMsg = v.array(value)
		if not arraySuccess then
			return false, arrayErrMsg
		end

		local valueSuccess, valueErrMsg = strictValuesCheck(value)
		if not valueSuccess then
			return false, valueErrMsg
		end

		return true
	end
end

do
	local callbackArray = v.strictArray(v.callback)

	-- creates a union type
	function v.union(...)
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
	function v.intersection(...)
		local checks = {...}
		assert(callbackArray(checks))
		return function(value)
			for _, check in pairs(checks) do
				local success, errMsg = check(value)
				if not success then
					return false, errMsg
				end
			end
			return true
		end
	end
end

function v.strictArray(check)
	assert(v.callback(check))
	return v.intersection(v.array, v.strictValues(check))
end

-- ensures value matches given interface definition
function v.interface(checkTable)
	assert(v.map(v.string, v.callback))
	return function(value)
		local tableSuccess, tableErrMsg = v.table(value)
		if tableSuccess == false then
			return false, tableErrMsg
		end

		for key, check in pairs(checkTable) do
			local success, errMsg = check(value[key])
			if success == false then
				return false, string.format("[interface] bad value for %s: %s", key, errMsg)
			end
		end
		return true
	end
end

-- ensure value is an Instance and it's ClassName matches the given ClassName
function v.instanceOf(className)
	assert(v.string(className))
	return function(value)
		local instanceSuccess, instanceErrMsg = v.Instance(value)
		if not instanceSuccess then
			return false, instanceErrMsg
		end

		if value.ClassName ~= className then
			return false, string.format("%s expected, got %s", className, value.ClassName)
		end

		return true
	end
end

-- ensure value is an Instance and it's ClassName matches the given ClassName by an IsA comparison
function v.instanceIsA(className)
	assert(v.string(className))
	return function(value)
		local instanceSuccess, instanceErrMsg = v.Instance(value)
		if not instanceSuccess then
			return false, instanceErrMsg
		end

		if not value:IsA(className) then
			return false, string.format("%s expected, got %s", className, value.ClassName)
		end

		return true
	end
end

return v
