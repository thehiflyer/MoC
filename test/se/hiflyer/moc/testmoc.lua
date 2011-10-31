require("se/hiflyer/moc/moc")

function testCreate()
	local mock = MoC:New()
	assertNotNil(mock)
end

function testIndex()
	local mock = MoC:New()
	assertNotNil(mock.foo)
	assertNotNil(mock.bar)
end

function assertError(expected, func, ...)
	local ok, actual = pcall(func, ...)
	assertEquals(false, ok)
	assertEquals(expected, actual)
end

function testVerifyOnce()
	local mock = MoC:New()

	assertError("Expected 1 call but got no calls", function() verifyOnce():on(mock):Foo() end)
	mock:Foo()
	verifyOnce():on(mock):Foo()

	assertError("Expected 1 call but got no calls", function() verifyOnce():on(mock):Bar() end)
end

function testVerifyExactly()
	local mock = MoC:New()

	assertError("Expected 2 calls but got no calls", function() verifyExactly(2):on(mock):Foo() end)

	mock:Foo()

	assertError("Expected 2 calls but got 1 call", function() verifyExactly(2):on(mock):Foo() end)
	mock:Foo()

	verifyExactly(2):on(mock):Foo()

	mock:Foo()

	assertError("Expected 2 calls but got 3 calls", function() verifyExactly(2):on(mock):Foo() end)
end


function testVerifyExactlyDifferentParams()
	local mock = MoC:New()

	mock:Foo()
	mock:Foo()

	assertError("Expected 2 calls but got no calls", function() verifyExactly(2):on(mock):Foo("Bar") end)

	mock:Foo("Bar")
	mock:Foo("Bar")

	verifyExactly(2):on(mock):Foo()
end

function testAtLeast()
	local mock = MoC:New()

	assertError("Expected at least 2 calls but got no calls", function() verifyAtLeast(2):on(mock):Foo() end)

	mock:Foo()

	assertError("Expected at least 2 calls but got 1 call", function() verifyAtLeast(2):on(mock):Foo() end)

	mock:Foo()
	verifyAtLeast(2):on(mock):Foo()
	mock:Foo()
	verifyAtLeast(2):on(mock):Foo()
end

function testAtMost()
	local mock = MoC:New()

	verifyAtMost(2):on(mock):Foo()

	mock:Foo()

	verifyAtMost(2):on(mock):Foo()
	mock:Foo()

	verifyAtMost(2):on(mock):Foo()

	mock:Foo()

	assertError("Expected at most 2 calls but got 3 calls", function() verifyAtMost(2):on(mock):Foo() end)
end

function testVerifyNever()
	local mock = MoC:New()

	verifyNever():on(mock):Foo()

	mock:Bar()
	verifyNever():on(mock):Foo()

	mock:Foo()

	assertError("Expected no calls but got 1 call", function() verifyNever():on(mock):Foo() end)
	mock:Foo()

	assertError("Expected no calls but got 2 calls", function() verifyNever():on(mock):Foo() end)
end

function testWhenReturn()
	local mock = MoC:New()
	when(mock:GetFoo()):thenReturn("bar")

	local bar = mock:GetFoo()
	assertEquals("bar", bar)
	verifyOnce():on(mock):GetFoo()
end

function testWhenReturnMultipleTimes()
	local mock = MoC:New()
	when(mock:GetFoo()):thenReturn("bar")

	for i = 1, 10 do
		local bar = mock:GetFoo()
		assertEquals("bar", bar)
	end
	verifyExactly(10):on(mock):GetFoo()
end


function testWhenReturnMultipleParameters()
	local mock = MoC:New()
	when(mock:GetFoo()):thenReturn("bar", "BAR")

	local bar, BAR = mock:GetFoo()
	assertEquals("bar", bar)
	assertEquals("BAR", BAR)

	verifyOnce():on(mock):GetFoo()
end


function testWhenChangeReturn()
	local mock = MoC:New()
	when(mock:GetFoo()):thenReturn("bar")

	local bar = mock:GetFoo()
	assertEquals("bar", bar)

	when(mock:GetFoo()):thenReturn("baz")

	local baz = mock:GetFoo()
	assertEquals("baz", baz)
	verifyExactly(2):on(mock):GetFoo()
end

function testWhenMatchingArguments()
	local mock = MoC:New()
	when(mock:GetFoo("foo")):thenReturn("bar")

	assertEquals("bar", mock:GetFoo("foo"))
	assertNil(mock:GetFoo())

	when(mock:GetFoo("a")):thenReturn("b")
	assertEquals("bar", mock:GetFoo("foo"))
	assertEquals("b", mock:GetFoo("a"))
end
