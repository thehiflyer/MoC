 --[[
 Copyright (c) 2011 Per Malmén (per.malmen@gmail.com)

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ]]

 --[[
  Find more information about MoC on https://github.com/thehiflyer/MoC
  ]]

require("se/hiflyer/moc/callhandler")

MoC = {__version = setmetatable({major = 0, minor = 2, build = 0}, {__tostring = function(e) return string.format("%d.%d.%d", e.major, e.minor, e.build)end})}

__latestInvocation = nil

function MoC:New()
	local this = {}
	setmetatable(this,
		{__index = function(t, k)
			local callHandler = rawget(t,k)
			if not callHandler then
				callHandler = CallHandler:New(1)
				rawset(t, k, callHandler)
			end
			return callHandler
		end })
	return this
end

local function getCallForValue(value)
	if(value == 0) then
		return "no calls"
	elseif(value == 1) then
		return "1 call"
	else
		return string.format("%s calls", value)
	end
end

function verifyWithComparator(comparator)
	return {on = function(self, mock)
		local onHandler = {}
		local meta = {
			__index = function(t, mockFunction)
				return function(...)
					local args = {n = select("#", ...), ...}
					local callHandler = mock[mockFunction]
					local actualInvocations = callHandler:GetNumberOfInvocationsMatchingParams(unpack(args))
					local success, compareResult = comparator(actualInvocations)
					if (not success) then
						error(compareResult)
					end
				end
			end
		}
		return setmetatable(onHandler, meta)
	end}
end

function verifyExactly(times)
	return verifyWithComparator(function(actual)
		if times ~=actual then
			return false, string.format("Expected %s but got %s", getCallForValue(times), getCallForValue(actual))
		end
		return true
	end)
end

function verifyAtLeast(times)
	return verifyWithComparator(function(actual)
		if times > actual then
			return false, string.format("Expected at least %s but got %s", getCallForValue(times), getCallForValue(actual))
		end
		return true
	end)
end

function verifyAtMost(times)
	return verifyWithComparator(function(actual)
		if times < actual then
			return false, string.format("Expected at most %s but got %s", getCallForValue(times), getCallForValue(actual))
		end
		return true
	end)
end

function verifyNever()
	return verifyExactly(0)
end

function verifyOnce()
	return verifyExactly(1)
end

function when(mockInvocation)
	local callHandler = __latestInvocation
	local lastCall = callHandler:RemoveLastestInvocation()
	return {
	 thenReturn = function(self, ...)
		 local returnArgs = {n = select("#", ...), ... }
		 callHandler:AddStub(lastCall, returnArgs)
	 end
 }
end