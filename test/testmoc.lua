require("lua/core/moc")

local __fail = fail

fail = function(message)
	lastFail = message
end

local function reset()
	lastFail = nil
end


function testCreate()
	local mock = MoC:New()
	assertNotNil(mock)
end

function testVerifyOnce()
	local mock = MoC:New()

	assertNil(lastFail)
	verifyOnce():on(mock):Foo()
	assertNotNil(lastFail)
	assertEquals("Expected 1 call but got no calls", lastFail)

	reset()
	mock:Foo()

	verifyOnce():on(mock):Foo()
	assertNil(lastFail)
	verifyOnce():on(mock):Bar()
	assertNotNil(lastFail)
	assertEquals("Expected 1 call but got no calls", lastFail)
end

function testVerifyExactly()
	local mock = MoC:New()

	assertNil(lastFail)
	verifyExactly(2):on(mock):Foo()
	assertNotNil(lastFail)
	assertEquals("Expected 2 calls but got no calls", lastFail)

	reset()
	mock:Foo()

	verifyExactly(2):on(mock):Foo()
	assertNotNil(lastFail)
	assertEquals("Expected 2 calls but got 1 call", lastFail)
	reset()
	mock:Foo()

	verifyExactly(2):on(mock):Foo()
	assertNil(lastFail)

	reset()
	mock:Foo()

	verifyExactly(2):on(mock):Foo()
	assertNotNil(lastFail)
	assertEquals("Expected 2 calls but got 3 calls", lastFail)

end

function testAtLeast()
	local mock = MoC:New()

	assertNil(lastFail)
	verifyAtLeast(2):on(mock):Foo()
	assertNotNil(lastFail)
	assertEquals("Expected at least 2 calls but got no calls", lastFail)

	reset()
	mock:Foo()

	verifyAtLeast(2):on(mock):Foo()
	assertNotNil(lastFail)
	assertEquals("Expected at least 2 calls but got 1 call", lastFail)
	reset()
	mock:Foo()

	verifyAtLeast(2):on(mock):Foo()
	assertNil(lastFail)

	reset()
	mock:Foo()

	verifyAtLeast(2):on(mock):Foo()
	assertNil(lastFail)
end

function testAtMost()
	local mock = MoC:New()

	assertNil(lastFail)
	verifyAtMost(2):on(mock):Foo()
	assertNil(lastFail)

	mock:Foo()

	verifyAtMost(2):on(mock):Foo()
	assertNil(lastFail)
	mock:Foo()

	verifyAtMost(2):on(mock):Foo()
	assertNil(lastFail)

	mock:Foo()

	verifyAtMost(2):on(mock):Foo()
	assertNotNil(lastFail)
	assertEquals("Expected at most 2 calls but got 3 calls", lastFail)
end

function testVerifyNever()
	local mock = MoC:New()

	assertNil(lastFail)
	verifyNever():on(mock):Foo()
	assertNil(lastFail)

	mock:Bar()
	verifyNever():on(mock):Foo()
	assertNil(lastFail)

	mock:Foo()

	verifyNever():on(mock):Foo()
	assertNotNil(lastFail)
	assertEquals("Expected no calls but got 1 call", lastFail)

	reset()
	mock:Foo()

	verifyNever():on(mock):Foo()
	assertNotNil(lastFail)
	assertEquals("Expected no calls but got 2 calls", lastFail)

end






