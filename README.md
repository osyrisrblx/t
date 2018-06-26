# v: A Runtime Typechecker for Roblox

v is a module which allows you to create type definitions to check values against.

## Why?
When building large systems, it can often be difficult to find type mismatch bugs.\
Typechecking helps you ensure that your functions are recieving the appropriate types for their arguments.

In Roblox specifically, it is important to type check your Remote objects to ensure that exploiters aren't sending you bad data which can cause your server to error (and potentially crash!).

## Crash Course
```Lua
local v = require(Path.To.v)

local fooCheck = v.tuple(v.string, v.number, v.optional(v.string))
local function foo(a, b, c)
	assert(fooCheck(a, b, c))
	-- you can now assume:
	--	a is a string
	--	b is a number
	--	c is either a string or nil
end

foo() --> error
foo("1", 2)
foo("1", 2, "3")
foo("1", 2, 3) --> error
```

Check out src/v.spec.lua for a variety of good examples!

## Primitives
|Type     |  |Member     |
|---------|--|-----------|
|boolean  |=>|v.boolean  |
|coroutine|=>|v.coroutine|
|function |=>|v.callback |
|nil      |=>|v.none     |
|number   |=>|v.number   |
|string   |=>|v.string   |
|table    |=>|v.table    |

Any primitive can be checked with a built-in primitive function.\
Primitives are found under the same name as their type name except for two:
- nil -> v.none
- function -> v.callback

These two are renamed due to Lua restrictions on reserved words.

All Roblox primitives are also available and can be found under their respective type names.\
We won't list them here to due how many there are, but as an example you can access a few like this:
```Lua
v.Instance
v.CFrame
v.Color3
v.Vector3
-- etc...
```

You can check values against these primitives like this:
```Lua
local x = 1
print(v.number(x)) --> true
print(v.string(x)) --> false
```

## Type Composition
Often, you can combine types to create a composition of types.\
For example:
```Lua
local mightBeAString = v.optional(v.string)
print(mightBeAString("Hello")) --> true
print(mightBeAString()) --> true
print(mightBeAString(1)) --> false
```

## Meta Type Functions
The real power of v is in the meta type functions.

**`v.any`**\
Passes if value is non-nil.

**`v.optional(check)`**\
Passes if value is either nil or passes `check`

**`v.tuple(...)`**\
You can define a tuple type with `v.tuple(...)`.\
The arguments should be a list of type checkers.

**`v.union(...)`**\
You can define a union type with `v.union(...)`.\
The arguments should be a list of type checkers.

**`v.strictKeys(check)`**\
Matches a table's keys against `check`

**`v.strictValues(check)`**\
Matches a table's values against `check`

**`v.map(keyCheck, valueCheck)`**\
Checks all of a table's keys against `keyCheck` and all of a table's values against `valueCheck`

## Special Number Functions

v includes a few special functions for checking numbers, these can be useful to ensure the given value is within a certain range.

**General:**\
**`v.integer`**\
checks `v.number` and determines if value is an integer

**`v.numberPositive`**\
checks `v.number` and determins if the value > 0

**`v.numberNegative`**\
checks `v.number` and determins if the value < 0

**Inclusive  Comparisons:**\
**`v.numberMin(min)`**\
checks `v.number` and determines if value >= min

**`v.numberMax(max)`**\
checks `v.number` and determines if value <= max

**`v.numberConstrained(min, max)`**\
checks `v.number` and determins if min <= value <= max

**Exclusive Comparisons:**\
**`v.numberMinExclusive(min)`**\
checks `v.number` and determines if value > min

**`v.numberMaxExclusive(max)`**\
checks `v.number` and determines if value < max

**`v.numberConstrainedExclusive(min, max)`**\
checks `v.number` and determins if min < value < max

## Arrays
In Lua, arrays are a special type of table where all the keys are sequential integers.\
v has special functions for checking against arrays.

**`v.array`**\
determines that the value is a table and all of it's keys are sequential integers.

**`v.strictArray(check)`**\
checks against `v.array` and ensures all of the values in the table match `check`

## Interfaces
Interfaces can be defined through `v.interface(definition)` where `definition` is a table of type checkers.\
For example:
```Lua
local IPlayer = v.interface({
	Name = v.string,
	Score = v.number,
})

local myPlayer = { Name = "TestPlayer", Score = 100 }
print(IPlayer(myPlayer)) --> true
print(IPlayer({})) --> false
```

You can use `v.optional(check)` to make an interface field optional or `v.union(...)` if a field can be multiple types.

You can even put interfaces inside interfaces!
```Lua
local IPlayer = v.interface({
	Name = v.string,
	Score = v.number,
	Inventory = v.interface({
		Size = v.number
	})
})

local myPlayer = {
	Name = "TestPlayer",
	Score = 100,
	Inventory = {
		Size = 20
	}
}
print(IPlayer(myPlayer)) --> true
```

## Roblox Instances
v includes two functions to check the types of Roblox Instances.

**`v.instanceOf(className)`**\
ensures the value is an Instance and it's ClassName exactly matches `className`

**`v.instanceIsA(className)`**\
ensures the value is an Instance and it's ClassName matches `className` by a IsA comparison. ([see here](http://wiki.roblox.com/index.php?title=API:Class/Instance/FindFirstAncestorWhichIsA))

## Tips and Tricks
You can create your own type checkers with a simple function that returns a boolean.\
These custom type checkers fit perfectly with the rest of v's functions.

If you roll your own custom OOP framework, you can easily integrate v with a custom typechecker.\
For example:
```Lua
local MyClass = {}
MyClass.__index = MyClass

function MyClass.new()
	local self = setmetatable({}, MyClass)
	-- setup instance
	return self
end

local function instanceOfClass(class)
	return function(value)
		return v.table(value) and getmetatable(value).__index == class
	end
end

local instanceOfMyClass = instanceOfClass(MyClass)

local myObject = MyClass.new()
print(instanceOfMyClass(myObject)) --> true
```

## Notes
This library was heavily inspired by [io-ts](https://github.com/gcanti/io-ts), a fantastic runtime type validation library for TypeScript.