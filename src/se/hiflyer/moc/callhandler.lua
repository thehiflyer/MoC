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

local function extend(index, parent)
	for k, v in pairs(parent) do
		if (k ~= "super") then
			index[k] = v
		end
	end
	return index
end


CallHandler = {}

local function IsMatching(parameters, invocation)
	local matching = false
	if (parameters.n == invocation.n) then
		matching = true
		for index = 1, parameters.n do
			matching = matching and parameters[index] == invocation[index]
		end
	end
	return matching
end


function CallHandler:New(skip_first)
	skip_first = skip_first or 0
	local this = {}
	extend(this, self)
	this.invocations = {}
	this.stubs = {}
	this.skip_first = skip_first
	local meta = {
		__call = function(t, ...)
			local invocation = { n = select("#", ...) - skip_first, select(skip_first + 1, ...) }
			table.insert(this.invocations, invocation)
			__latestInvocation = t
			local stub
			for i = 1, #this.stubs do
				if (IsMatching(this.stubs[i].invocation, invocation)) then
					stub = this.stubs[i].returnValues
				end
			end

			if (stub) then
				return unpack(stub)
			else
				return nil
			end
		end
	}
	setmetatable(this, meta)
	return this
end


function CallHandler:RemoveLastestInvocation()
	return table.remove(self.invocations)
end

function CallHandler:AddStub(matchingInvocation, stub)
	table.insert(self.stubs, { invocation = matchingInvocation, returnValues = stub })
end



function CallHandler:GetNumberOfInvocationsMatchingParams(...)
	local matchingInvocations = 0
	local skip_first = self.skip_first
	local parameters = { n = select("#", ...) - skip_first, select(skip_first + 1, ...) }

	for ordinal, invocation in pairs(self.invocations) do
		if (IsMatching(parameters, invocation)) then
			matchingInvocations = matchingInvocations + 1
		end
	end
	return matchingInvocations
end



