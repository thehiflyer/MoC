require("se/hiflyer/moc/callhandler")

function testCreate()
	local callHandler = CallHandler:New()
	assertNotNil(callHandler)
end


function testCall()
	local callHandler = CallHandler:New()
	callHandler()
end

function testCallCount()
	local callHandler = CallHandler:New()
	assertEquals(0, callHandler:GetNumberOfInvocationsMatchingParams())
	callHandler()
	assertEquals(1, callHandler:GetNumberOfInvocationsMatchingParams())
	callHandler()
	assertEquals(2, callHandler:GetNumberOfInvocationsMatchingParams())
end

function testCallWithNumberOfParams()
	local callHandler = CallHandler:New()
	assertEquals(0, callHandler:GetNumberOfInvocationsMatchingParams("Foo"))
	callHandler("Foo")
	assertEquals(1, callHandler:GetNumberOfInvocationsMatchingParams("Foo"))
	assertEquals(0, callHandler:GetNumberOfInvocationsMatchingParams())
end

function testCallWithNotEqualsParams()
	local callHandler = CallHandler:New()
	callHandler("Foo")
	assertEquals(1, callHandler:GetNumberOfInvocationsMatchingParams("Foo"))
	assertEquals(0, callHandler:GetNumberOfInvocationsMatchingParams("Bar"))
end

function testCallWithManyNonMatching()
	local callHandler = CallHandler:New()
	assertEquals(0, callHandler:GetNumberOfInvocationsMatchingParams("Foo"))
	callHandler("Foo")
	assertEquals(0, callHandler:GetNumberOfInvocationsMatchingParams("Bar", "far", "baz"))
end

