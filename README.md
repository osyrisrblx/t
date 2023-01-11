<h1 align="center">t</h1>
<div align="center">
	<a href="https://github.com/osyrisrblx/t/actions">
		<img src="https://github.com/osyrisrblx/t/workflows/CI/badge.svg" alt="CI Status" />
	</a>
	<a href='https://coveralls.io/github/osyrisrblx/t?branch=master'>
		<img src='https://coveralls.io/repos/github/osyrisrblx/t/badge.svg?branch=master' alt='Coverage Status' />
	</a>
</div>

<div align="center">
	A Runtime Type Checker for Roblox
</div>

<div>&nbsp;</div>

t is a module which allows you to create type definitions to check values against.

## Download
[You can download the latest copy of t here.](https://raw.githubusercontent.com/osyrisrblx/t/master/lib/init.lua)

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
|thread   |=>|t.thread   |
|function |=>|t.callback |
|nil      |=>|t.none     |
|number   |=>|t.number   |
|string   |=>|t.string   |
|table    |=>|t.table    |
|userdata |=>|t.userdata |

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
print(t.string(x)) --> false, "string expected, got number"
```

## Type Composition
Often, you can combine types to create a composition of types.\
For example:
```Lua
local mightBeAString = t.optional(t.string)
print(mightBeAString("Hello")) --> true
print(mightBeAString()) --> true
print(mightBeAString(1)) --> false, "(optional) string expected, got number"
```

These get denoted as function calls below with specified arguments. `check` can be any other type checker.

## Meta Type Functions
The real power of t is in the meta type functions.

**`t.any`**\
Passes if value is non-nil.

**`t.literal(...)`**\
Passes if value matches any given value exactly.

**`t.keyOf(keyTable)`**\
Returns a t.union of each key in the table as a t.literal

**`t.valueOf(valueTable)`**\
Returns a t.union of each value in the table as a t.literal

**`t.optional(check)`**\
Passes if value is either nil or passes `check`

**`t.tuple(...)`**\
You can define a tuple type with `t.tuple(...)`.\
The arguments should be a list of type checkers.

**`t.union(...)`** - ( alias: `t.some(...)` )\
You can define a union type with `t.union(...)`.\
The arguments should be a list of type checkers.\
**At least one check must pass**\
i.e. `t.union(a, b, c)` -> `a OR b OR c`

**`t.intersection(...)`** - ( alias: `t.every(...)` )\
You can define an intersection type with `t.intersection(...)`.\
The arguments should be a list of type checkers.\
**All checks must pass**\
i.e. `t.intersection(a, b, c)` -> `a AND b AND c`

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
**`t.nan`**\
determines if value is `NaN`\
All of the following checks will not pass for `NaN` values.\
If you need to allow for `NaN`, use `t.union(t.number, t.nan)`

**`t.integer`**\
checks `t.number` and determines if value is an integer

**`t.numberPositive`**\
checks `t.number` and determines if the value > 0

**`t.numberNegative`**\
checks `t.number` and determines if the value < 0

**Inclusive  Comparisons:**\
**`t.numberMin(min)`**\
checks `t.number` and determines if value >= min

**`t.numberMax(max)`**\
checks `t.number` and determines if value <= max

**`t.numberConstrained(min, max)`**\
checks `t.number` and determines if min <= value <= max

**Exclusive Comparisons:**\
**`t.numberMinExclusive(min)`**\
checks `t.number` and determines if value > min

**`t.numberMaxExclusive(max)`**\
checks `t.number` and determines if value < max

**`t.numberConstrainedExclusive(min, max)`**\
checks `t.number` and determines if min < value < max

## Special String Functions

t includes a few special functions for checking strings

**`t.match(pattern)`**\
checks `t.string` and determines if value matches the pattern via `string.match(value, pattern)`

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
print(IPlayer({})) --> false, "[interface] bad value for Name: string expected, got nil"
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

If you want to make sure an value _exactly_ matches a given interface (no extra fields),\
you can use `t.strictInterface(definition)` where `definition` is a table of type checkers.\
For example:
```Lua
local IPlayer = t.strictInterface({
	Name = t.string,
	Score = t.number,
})

local myPlayer1 = { Name = "TestPlayer", Score = 100 }
local myPlayer2 = { Name = "TestPlayer", Score = 100, A = 1 }
print(IPlayer(myPlayer1)) --> true
print(IPlayer(myPlayer2)) --> false, "[interface] unexpected field 'A'"
```

## Roblox Instances
t includes two functions to check the types of Roblox Instances.

**`t.instanceOf(className[, childTable])`**\
ensures the value is an Instance and it's ClassName exactly matches `className`\
If you provide a `childTable`, it will be automatically passed to `t.children()`

**`t.instanceIsA(className[, childTable])`**\
ensures the value is an Instance and it's ClassName matches `className` by a IsA comparison. ([see here](http://wiki.roblox.com/index.php?title=API:Class/Instance/FindFirstAncestorWhichIsA))

**`t.children(checkTable)`**\
Takes a table where keys are child names and values are functions to check the children against.\
Pass an instance tree into the function.

**Warning! If you pass in a tree with more than one child of the same name, this function will always return false**

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

You can put a `t.tuple(...)` inside an array or interface, but that doesn't really make any sense..\
In the future, this may error.

## Notes
This library was heavily inspired by [io-ts](https://github.com/gcanti/io-ts), a fantastic runtime type validation library for TypeScript.

## Why did you name it t?
The whole idea is that most people import modules via:\
`local X = require(path.to.X)`\
So whatever I name the library will be what people name the variable.\
If I made the name of the library longer, the type definitions become more noisy / less readable.\
Things like this are pretty common:\
`local fooCheck = t.tuple(t.string, t.number, t.optional(t.string))`
