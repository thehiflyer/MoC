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

MoC = {__version = {major = 0, minor = 1, build = 0}}

function createmock()
	return setmetatable({invocations={}}, {__call = function(t, ...)
		table.insert(t.invocations, {n=select("#", ...), ...})
	end})
end

function MoC:New()
	local this = {}
	setmetatable(this, {__index = function(t, k) local x=createmock()
              rawset(t, k, x) return x end })
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
		return setmetatable({}, {__index = function(t, mockFunction)
			return function(func, ...)
				local invocationsTable = mock[mockFunction].invocations
				local actualInvocations = #invocationsTable
				local success, compareResult = comparator(actualInvocations)
				if(not success) then
					fail(compareResult)
				end
			end
		end})
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