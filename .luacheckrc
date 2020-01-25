-- luacheck: ignore
globals = {
	-- global variables
	"game", "script",

	-- global functions
	"delay", "getfenv", "setfenv", "settings", "spawn", "tick", "time",
	"typeof", "unpack", "UserSettings", "wait", "warn", "version",

	-- types
	"Axes", "BrickColor", "CFrame", "Color3", "ColorSequence", "ColorSequenceKeypoint",
	"Enum", "Faces", "Instance", "NumberRange", "NumberSequence", "NumberSequenceKeypoint",
	"PhysicalProperties", "Random", "Ray", "Rect", "Region3", "Region3int16", "TweenInfo",
	"UDim", "UDim2", "Vector2", "Vector3", "Vector3int16",

	-- math library
	"math.clamp", "math.noise", "math.sign",

	-- debug library
	"debug.profilebegin", "debug.profileend",

	"it", "expect", "describe",
}

-- fix methods
ignore = {"self", "super"}

-- prevent max line lengths
max_line_length = false
max_code_line_length = false
max_string_line_length = false
max_comment_line_length = false