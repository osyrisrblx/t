local t = require("src/t")

-- basic types
do
	assert(t.boolean(true) == true)
	assert(t.number(1) == true)
	assert(t.string("foo") == true)
	assert(t.table({}) == true)

	assert(t.boolean("true") == false)
	assert(t.number(true) == false)
	assert(t.string(true) == false)
	assert(t.table(82) == false)
end

-- numbers
do
	local maxTen = t.numberMax(10)
	local minTwo = t.numberMin(2)
	local constrainedEightToEleven = t.numberConstrained(8, 11)
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
	local check = t.optional(t.string)
	assert(check("") == true)
	assert(check() == true)
	assert(check(1) == false)
end

-- tuple
do
	local myTupleCheck = t.tuple(t.number, t.string, t.optional(t.number))
	assert(myTupleCheck(1, "2", 3) == true)
	assert(myTupleCheck(1, "2") == true)
	assert(myTupleCheck(1, "2", "3") == false)
end

-- union
do
	local numberOrString = t.union(t.number, t.string)
	assert(numberOrString(1) == true)
	assert(numberOrString("1") == true)
	assert(numberOrString(nil) == false)
end

-- intersection
do
	local integerMax5000 = t.intersection(t.integer, t.numberMax(5000))
	assert(integerMax5000(1) == true)
	assert(integerMax5000(5001) == false)
	assert(integerMax5000(1.1) == false)
	assert(integerMax5000("1") == false)
end

-- array
do
	local stringArray = t.strictArray(t.string)
	assert(t.array("foo") == false)
	assert(t.array({1, "2", 3}) == true)
	assert(stringArray({1, "2", 3}) == false)
	assert(t.array({"1", "2", "3"}, t.string) == true)
	assert(t.array({
		foo = "bar"
	}) == false)
end

-- interface
do
	local IVector3 = t.interface({
		x = t.number,
		y = t.number,
		z = t.number,
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
	local IPlayer = t.interface({
		name = t.string,
		inventory = t.interface({
			size = t.number
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
	local IPlayer = t.interface({
		name = t.string,
		inventory = t.optional(t.interface({
			size = t.number
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