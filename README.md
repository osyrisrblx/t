<h1 align="center">t</h1>
<div align="center">
	<a href="https://travis-ci.org/osyrisrblx/t">
		<img src="https://api.travis-ci.org/osyrisrblx/t.svg?branch=master" alt="Travis-CI Build Status" />
	</a>
	<a href='https://coveralls.io/github/osyrisrblx/t?branch=master'>
		<img src='https://coveralls.io/repos/github/osyrisrblx/t/badge.svg' alt='Coverage Status' />
	</a>
</div>

<div align="center">
	A Runtime Type Checker for Roblox
</div>

<div>&nbsp;</div>

t is a module which allows you to create type definitions to check values against.

## Why?
When building large systems, it can often be difficult to find type mismatch bugs.\
Typechecking helps you ensure that your functions are recieving the appropriate types for their arguments.

In Roblox specifically, it is important to type check your Remote objects to ensure that exploiters aren't sending you bad data which can cause your server to error (and potentially crash!).

## Crash Course
```Lua
local t = require(path.to.t)

local fooCheck = t.tuple(t.string, t.number, t.optional(t.string))
local function foo(a, b, c)
	assert(fooCheck(a, b, c))
	-- you can now assume:
	--	a is a string
	--	b is a number
	--	c is either a string or nil
end

foo() --> Error: Bad tuple index #1: string expected, got nil
foo("1", 2)
foo("1", 2, "3")
foo("1", 2, 3) --> Error: Bad tuple index #3: (optional) string expected, got number
```

Check out src/t.spec.lua for a variety of good examples!

## Primitives
|Type     |  |Member     |
|---------|--|-----------|
|boolean  |=>|t.boolean  |
|coroutine|=>|t.coroutine|
|function |=>|t.callback |
|nil      |=>|t.none     |
|number   |=>|t.number   |
|string   |=>|t.string   |
|table    |=>|t.table    |

Any primitive can be checked with a built-in primitive function.\
Primitives are found under the same name as their type name except for two:
- nil -> t.none
- function -> t.callback

These two are renamed due to Lua restrictions on reserved words.

All Roblox primitives are also available and can be found under their respective type names.\
We won't list them here to due how many there are, but as an example you can access a few like this:
```Lua
t.Instance
t.CFrame
t.Color3
t.Vector3
-- etc...
```

You can check values against these primitives like this:
```Lua
local x = 1
print(t.number(x)) --> true
print(t.string(x)) --> false
```

## Type Composition
Often, you can combine types to create a composition of types.\
For example:
```Lua
local mightBeAString = t.optional(t.string)
print(mightBeAString("Hello")) --> true
print(mightBeAString()) --> true
print(mightBeAString(1)) --> false
```

These get denoted as function calls below with specified arguments. `check` can be any other type checker.

## Meta Type Functions
The real power of t is in the meta type functions.

**`t.any`**\
Passes if value is non-nil.

**`t.optional(check)`**\
Passes if value is either nil or passes `check`

**`t.tuple(...)`**\
You can define a tuple type with `t.tuple(...)`.\
The arguments should be a list of type checkers.

**`t.union(...)`**\
You can define a union type with `t.union(...)`.\
The arguments should be a list of type checkers.

**`t.intersection(...)`**\
You can define an intersection type with `t.intersection(...)`.\
The arguments should be a list of type checkers.

**`t.keys(check)`**\
Matches a table's keys against `check`

**`t.values(check)`**\
Matches a table's values against `check`

**`t.map(keyCheck, valueCheck)`**\
Checks all of a table's keys against `keyCheck` and all of a table's values against `valueCheck`

There's also type checks for arrays and interfaces but we'll cover those in their own sections!

## Special Number Functions

t includes a few special functions for checking numbers, these can be useful to ensure the given value is within a certain range.

**General:**\
**`t.integer`**\
checks `t.number` and determines if value is an integer

**`t.numberPositive`**\
checks `t.number` and determins if the value > 0

**`t.numberNegative`**\
checks `t.number` and determins if the value < 0

**Inclusive  Comparisons:**\
**`t.numberMin(min)`**\
checks `t.number` and determines if value >= min

**`t.numberMax(max)`**\
checks `t.number` and determines if value <= max

**`t.numberConstrained(min, max)`**\
checks `t.number` and determins if min <= value <= max

**Exclusive Comparisons:**\
**`t.numberMinExclusive(min)`**\
checks `t.number` and determines if value > min

**`t.numberMaxExclusive(max)`**\
checks `t.number` and determines if value < max

**`t.numberConstrainedExclusive(min, max)`**\
checks `t.number` and determins if min < value < max

## Arrays
In Lua, arrays are a special type of table where all the keys are sequential integers.\
t has special functions for checking against arrays.

**`t.array(check)`**\
determines that the value is a table and all of it's keys are sequential integers and ensures all of the values in the table match `check`

## Interfaces
Interfaces can be defined through `t.interface(definition)` where `definition` is a table of type checkers.\
For example:
```Lua
local IPlayer = t.interface({
	Name = t.string,
	Score = t.number,
})

local myPlayer = { Name = "TestPlayer", Score = 100 }
print(IPlayer(myPlayer)) --> true
print(IPlayer({})) --> false
```

You can use `t.optional(check)` to make an interface field optional or `t.union(...)` if a field can be multiple types.

You can even put interfaces inside interfaces!
```Lua
local IPlayer = t.interface({
	Name = t.string,
	Score = t.number,
	Inventory = t.interface({
		Size = t.number
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
t includes two functions to check the types of Roblox Instances.

**`t.instance(className)`**\
ensures the value is an Instance and it's ClassName exactly matches `className`

**`t.instanceIsA(className)`**\
ensures the value is an Instance and it's ClassName matches `className` by a IsA comparison. ([see here](http://wiki.roblox.com/index.php?title=API:Class/Instance/FindFirstAncestorWhichIsA))

## Roblox Enums

t allows type checking for Roblox Enums!

**`t.Enum`**\
Ensures the value is an Enum, i.e. `Enum.Material`.

**`t.EnumItem`**\
Ensures the value is an EnumItem, i.e. `Enum.Material.Plastic`.

but the real power here is:

**`t.enum(enum)`**\
This will pass if value is an EnumItem which belongs to `enum`.

## Function Wrapping
Here's a common pattern people use when working with t:
```Lua
local fooCheck = t.tuple(t.string, t.number, t.optional(t.string))
local function foo(a, b, c)
	assert(fooCheck(a, b, c))
	-- function now assumes a, b, c are valid
end
```

**`t.wrap(callback, argCheck)`**\
`t.wrap(callback, argCheck)` allows you to shorten this to the following:
```Lua
local fooCheck = t.tuple(t.string, t.number, t.optional(t.string))
local foo = t.wrap(function(a, b, c)
	-- function now assumes a, b, c are valid
end, fooCheck)
```

OR

```Lua
local foo = t.wrap(function(a, b, c)
	-- function now assumes a, b, c are valid
end, t.tuple(t.string, t.number, t.optional(t.string)))
```

Alternatively, there's also:
**`t.strict(check)`**\
wrap your whole type in `t.strict(check)` and it will run an `assert` on calls.\
The example from above could alternatively look like:
```Lua
local fooCheck = t.strict(t.tuple(t.string, t.number, t.optional(t.string)))
local function foo(a, b, c)
	fooCheck(a, b, c)
	-- function now assumes a, b, c are valid
end
```

## Tips and Tricks
You can create your own type checkers with a simple function that returns a boolean.\
These custom type checkers fit perfectly with the rest of t's functions.

If you roll your own custom OOP framework, you can easily integrate t with a custom type checker.\
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
		local tableSuccess, tableErrMsg = t.table(value)
		if not tableSuccess then
			return false, tableErrMsg or "" -- pass error message for value not being a table
		end

		local mt = getmetatable(value)
		if not mt or mt.__index ~= class then
			return false, "bad member of class" -- custom error message
		end

		return true -- all checks passed
	end
end

local instanceOfMyClass = instanceOfClass(MyClass)

local myObject = MyClass.new()
print(instanceOfMyClass(myObject)) --> true
```

## Known Issues

You can put a `t.tuple(...)` inside an array or interface, but that doesn't really make any sense..
In the future, this may error.

## Notes
This library was heavily inspired by [io-ts](https://github.com/gcanti/io-ts), a fantastic runtime type validation library for TypeScript.