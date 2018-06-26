local v = require("src/v")

-- basic types
do
	assert(v.boolean(true) == true)
	assert(v.number(1) == true)
	assert(v.string("foo") == true)
	assert(v.table({}) == true)

	assert(v.boolean("true") == false)
	assert(v.number(true) == false)
	assert(v.string(true) == false)
	assert(v.table(82) == false)
end

-- numbers
do
	local maxTen = v.numberMax(10)
	local minTwo = v.numberMin(2)
	local constrainedEightToEleven = v.numberConstrained(8, 11)
	assert(maxTen(5) == true)
	assert(maxTen(10) == true)
	assert(maxTen(11) == false)
	assert(minTwo(5) == true)
	assert(minTwo(2) == true)
	assert(minTwo(1) == false)
	assert(constrainedEightToEleven(7) == false)
	assert(constrainedEightToEleven(8) == true)
	assert(constrainedEightToEleven(9) == true)
	assert(constrainedEightToEleven(11) == true)
	assert(constrainedEightToEleven(12) == false)
end

-- optional
do
	local check = v.optional(v.string)
	assert(check("") == true)
	assert(check() == true)
	assert(check(1) == false)
end

-- tuple
do
	local myTupleCheck = v.tuple(v.number, v.string, v.optional(v.number))
	assert(myTupleCheck(1, "2", 3) == true)
	assert(myTupleCheck(1, "2") == true)
	assert(myTupleCheck(1, "2", "3") == false)
end

-- array
do
	local stringArray = v.strictArray(v.string)
	assert(v.array("foo") == false)
	assert(v.array({1, "2", 3}) == true)
	assert(stringArray({1, "2", 3}) == false)
	assert(v.array({"1", "2", "3"}, v.string) == true)
	assert(v.array({
		foo = "bar"
	}) == false)
end

-- interface
do
	local IVector3 = v.interface({
		x = v.number,
		y = v.number,
		z = v.number,
	})

	assert(IVector3({
		w = 0,
		x = 1,
		y = 2,
		z = 3,
	}) == true)

	assert(IVector3({
		w = 0,
		x = 1,
		y = 2,
	}) == false)
end

-- deep interface
do
	local IPlayer = v.interface({
		name = v.string,
		inventory = v.interface({
			size = v.number
		})
	})

	assert(IPlayer({
		name = "TestPlayer",
		inventory = {
			size = 1
		}
	}) == true)

	assert(IPlayer({
		inventory = {
			size = 1
		}
	}) == false)

	assert(IPlayer({
		name = "TestPlayer",
		inventory = {
		}
	}) == false)

	assert(IPlayer({
		name = "TestPlayer",
	}) == false)
end

-- deep optional interface
do
	local IPlayer = v.interface({
		name = v.string,
		inventory = v.optional(v.interface({
			size = v.number
		}))
	})

	assert(IPlayer({
		name = "TestPlayer"
	}) == true)

	assert(IPlayer({
		name = "TestPlayer",
		inventory = {
		}
	}) == false)

	assert(IPlayer({
		name = "TestPlayer",
		inventory = {
			size = 1
		}
	}) == true)
end