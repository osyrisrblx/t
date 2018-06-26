-- t: a runtime typechecker for Roblox
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

local t = {}

function t.any(value)
	if value ~= nil then
		return true
	else
		return "any expected, got nil"
	end
end

-- lua types
t.boolean = primitive("boolean")
t.coroutine = primitive("coroutine")
t.callback = primitive("function")
t.none = primitive("nil")
t.number = primitive("number")
t.string = primitive("string")
t.table = primitive("table")

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

-- ensures value is an integer
function t.integer(value)
	local success, errMsg = t.number(value)
	if not success then
		return false, errMsg or ""
	end
	if value%1 == 0 then
		return true
	else
		return false, "integer expected, got non-integer"
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
			return false, string.format("number >= %d expected", min)
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
			return false, string.format("number <= %d expected", max)
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
			return false, string.format("number > %d expected", min)
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
			return false, string.format("number < %d expected", max)
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
				return false, string.format("Bad tuple index #%d: %s", i, errMsg or "")
			end
		end
		return true
	end
end

-- ensures all keys in given table pass check
function t.strictKeys(check)
	assert(t.callback(check))
	return function(value)
		local tableSuccess, tableErrMsg = t.table(value)
		if tableSuccess == false then
			return false, tableErrMsg or ""
		end

		for key in pairs(value) do
			local success, errMsg = check(key)
			if success == false then
				return false, string.format("table bad key %s: %s", key, errMsg or "")
			end
		end

		return true
	end
end

-- ensures all values in given table pass check
function t.strictValues(check)
	assert(t.callback(check))
	return function(value)
		local tableSuccess, tableErrMsg = t.table(value)
		if tableSuccess == false then
			return false, tableErrMsg or ""
		end

		for _, val in pairs(value) do
			local success, errMsg = check(val)
			if success == false then
				return false, string.format("table bad value, got %s: %s", typeof(value), errMsg or "")
			end
		end

		return true
	end
end

-- ensures value is a table and all keys pass keyCheck and all values pass valueCheck
function t.map(keyCheck, valueCheck)
	assert(t.callback(keyCheck), t.callback(valueCheck))
	local keyChecker = t.strictKeys(keyCheck)
	local valueChecker = t.strictValues(valueCheck)
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


-- ensures value is an array
do
	local arrayKeysCheck = t.strictKeys(t.integer)
	function t.array(value)
		local keySuccess, keyErrMsg = arrayKeysCheck(value)
		if keySuccess == false then
			return false, keyErrMsg or ""
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
function t.strictArray(check)
	assert(t.callback(check))
	local strictValuesCheck = t.strictValues(check)
	return function(value)
		local arraySuccess, arrayErrMsg = t.array(value)
		if not arraySuccess then
			return false, arrayErrMsg or ""
		end

		local valueSuccess, valueErrMsg = strictValuesCheck(value)
		if not valueSuccess then
			return false, valueErrMsg or ""
		end

		return true
	end
end

do
	local callbackArray = t.strictArray(t.callback)

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

function t.strictArray(check)
	assert(t.callback(check))
	return t.intersection(t.array, t.strictValues(check))
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
				return false, string.format("[interface] bad value for %s: %s", key, errMsg or "")
			end
		end
		return true
	end
end

-- ensure value is an Instance and it's ClassName matches the given ClassName
function t.instanceOf(className)
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

return t
