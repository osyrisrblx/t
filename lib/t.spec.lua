return function()
	local t = require(script.Parent.t)

	it("should understand basic types", function()
		expect(t.boolean(true)).to.equal(true)
		expect(t.number(1)).to.equal(true)
		expect(t.string("foo")).to.equal(true)
		expect(t.table({})).to.equal(true)

		expect(t.boolean("true")).to.equal(false)
		expect(t.number(true)).to.equal(false)
		expect(t.string(true)).to.equal(false)
		expect(t.table(82)).to.equal(false)
	end)

	it("should understand special number types", function()
		local maxTen = t.numberMax(10)
		local minTwo = t.numberMin(2)
		local constrainedEightToEleven = t.numberConstrained(8, 11)
		expect(maxTen(5)).to.equal(true)
		expect(maxTen(10)).to.equal(true)
		expect(maxTen(11)).to.equal(false)
		expect(minTwo(5)).to.equal(true)
		expect(minTwo(2)).to.equal(true)
		expect(minTwo(1)).to.equal(false)
		expect(constrainedEightToEleven(7)).to.equal(false)
		expect(constrainedEightToEleven(8)).to.equal(true)
		expect(constrainedEightToEleven(9)).to.equal(true)
		expect(constrainedEightToEleven(11)).to.equal(true)
		expect(constrainedEightToEleven(12)).to.equal(false)
	end)

	it("should understand optional", function()
		local check = t.optional(t.string)
		expect(check("")).to.equal(true)
		expect(check()).to.equal(true)
		expect(check(1)).to.equal(false)
	end)

	it("should understand tuples", function()
		local myTupleCheck = t.tuple(t.number, t.string, t.optional(t.number))
		expect(myTupleCheck(1, "2", 3)).to.equal(true)
		expect(myTupleCheck(1, "2")).to.equal(true)
		expect(myTupleCheck(1, "2", "3")).to.equal(false)
	end)

	it("should understand unions", function()
		local numberOrString = t.union(t.number, t.string)
		expect(numberOrString(1)).to.equal(true)
		expect(numberOrString("1")).to.equal(true)
		expect(numberOrString(nil)).to.equal(false)
	end)

	it("should understand intersections", function()
		local integerMax5000 = t.intersection(t.integer, t.numberMax(5000))
		expect(integerMax5000(1)).to.equal(true)
		expect(integerMax5000(5001)).to.equal(false)
		expect(integerMax5000(1.1)).to.equal(false)
		expect(integerMax5000("1")).to.equal(false)
	end)

	it("should understand arrays", function()
		local stringArray = t.strictArray(t.string)
		expect(t.array("foo")).to.equal(false)
		expect(t.array({1, "2", 3})).to.equal(true)
		expect(stringArray({1, "2", 3})).to.equal(false)
		expect(t.array({"1", "2", "3"}, t.string)).to.equal(true)
		expect(t.array({
			foo = "bar"
		})).to.equal(false)
	end)

	it("should understand interfaces", function()
		local IVector3 = t.interface({
			x = t.number,
			y = t.number,
			z = t.number,
		})

		expect(IVector3({
			w = 0,
			x = 1,
			y = 2,
			z = 3,
		})).to.equal(true)

		expect(IVector3({
			w = 0,
			x = 1,
			y = 2,
		})).to.equal(false)
	end)

	it("should understand deep interfaces", function()
		local IPlayer = t.interface({
			name = t.string,
			inventory = t.interface({
				size = t.number
			})
		})

		expect(IPlayer({
			name = "TestPlayer",
			inventory = {
				size = 1
			}
		})).to.equal(true)

		expect(IPlayer({
			inventory = {
				size = 1
			}
		})).to.equal(false)

		expect(IPlayer({
			name = "TestPlayer",
			inventory = {
			}
		})).to.equal(false)

		expect(IPlayer({
			name = "TestPlayer",
		})).to.equal(false)
	end)

	it("should understand deep optional interfaces", function()
		local IPlayer = t.interface({
			name = t.string,
			inventory = t.optional(t.interface({
				size = t.number
			}))
		})

		expect(IPlayer({
			name = "TestPlayer"
		})).to.equal(true)

		expect(IPlayer({
			name = "TestPlayer",
			inventory = {
			}
		})).to.equal(false)

		expect(IPlayer({
			name = "TestPlayer",
			inventory = {
				size = 1
			}
		})).to.equal(true)
	end)
end