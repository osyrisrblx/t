-- v: a runtime typechecker for Roblox
-- Osyris

-- regular lua compatibility
local typeof = typeof or type

local function primitive(typeName)
	return function(value)
		return typeof(value) == typeName
	end
end

local v = {}

function v.any(value)
	return value ~= nil
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
	return v.number(value) and value%1 == 0
end

-- ensures value is a number where min <= value
function v.numberMin(min)
	return function(value)
		return v.number(value) and min <= value
	end
end

-- ensures value is a number where value <= max
function v.numberMax(max)
	return function(value)
		return v.number(value) and value <= max
	end
end

-- ensures value is a number where min < value
function v.numberMinExclusive(min)
	return function(value)
		return v.number(value) and min < value
	end
end

-- ensures value is a number where value < max
function v.numberMaxExclusive(max)
	return function(value)
		return v.number(value) and value < max
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
		return minCheck(value) and maxCheck(value)
	end
end

-- ensures value is a number where min < value < max
function v.numberConstrainedExclusive(min, max)
	assert(v.number(min) and v.number(max))
	local minCheck = v.numberMinExclusive(min)
	local maxCheck = v.numberMaxExclusive(max)
	return function(value)
		return minCheck(value) and maxCheck(value)
	end
end

-- ensures value is either nil or passes check
function v.optional(check)
	assert(v.callback(check))
	return function(value)
		return value == nil or check(value)
	end
end

-- matches given tuple against tuple type definition
function v.tuple(...)
	local checks = {...}
	return function(...)
		local args = {...}
		for i = 1, #args do
			if checks[i](args[i]) == false then
				return false
			end
		end
		return true
	end
end

-- ensures all keys in given table pass check
function v.strictKeys(check)
	assert(v.callback(check))
	return function(value)
		if v.table(value) == false then
			return false
		end

		for key in pairs(value) do
			if check(key) == false then
				return false
			end
		end

		return true
	end
end

-- ensures all values in given table pass check
function v.strictValues(check)
	assert(v.callback(check))
	return function(value)
		if v.table(value) == false then
			return false
		end

		for _, val in pairs(value) do
			if check(val) == false then
				return false
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
		return keyChecker(value) and valueChecker(value)
	end
end


-- ensures value is an array
do
	local arrayKeysCheck = v.strictKeys(v.number)
	function v.array(value)
		if arrayKeysCheck(value) == false then
			return false
		end

		-- all keys are sequential
		local expected = 1
		for i = 1, #value do
			if i == expected then
				if value[i] ~= nil then
					expected = expected + 1
				end
			else
				return false
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
		return v.array(value) and strictValuesCheck(value)
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
			return false
		end
	end

	-- creates an intersection type
	function v.intersection(...)
		local checks = {...}
		assert(callbackArray(checks))
		return function(value)
			for _, check in pairs(checks) do
				if not check(value) then
					return false
				end
			end
			return true
		end
	end
end

-- ensures value matches given interface definition
function v.interface(checkTable)
	assert(v.map(v.string, v.callback))
	return function(value)
		if v.table(value) == false then
			return false
		end

		for key, check in pairs(checkTable) do
			if check(value[key]) == false then
				return false
			end
		end
		return true
	end
end

-- ensure value is an Instance and it's ClassName matches the given ClassName
function v.instanceOf(className)
	assert(v.string(className))
	return function(value)
		return v.Instance(value) and value.ClassName == className
	end
end

-- ensure value is an Instance and it's ClassName matches the given ClassName by an IsA comparison
function v.instanceIsA(className)
	assert(v.string(className))
	return function(value)
		return v.Instance(value) and value:IsA(className)
	end
end

return v
