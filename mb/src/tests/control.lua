local control = require "mb.control"
local timer = require "cbclua.timer"
local string = require "string"
local math = require "math"
local table = require "table"

function test_time_sequence()
	local times = {.1, .2, .3, .35, .6, 1, 1.4}
	local timelog = { }
	local start = timer.seconds()
	
	local function add_timelog()
		table.insert(timelog, timer.seconds() - start)
	end
	
	local timeseq = { }
	for i, time in ipairs(times) do
		timeseq[i] = {time, add_timelog}
	end

	control.time_sequence(timeseq)
	
	for i=1,#times do
		if timelog[i] == nil then
			error("Missing timelog entry #" .. i)
		elseif math.abs(timelog[i] - times[i]) > .1 then
			error("Time skew on timelog entry #" .. i)
		end
	end
end

function test_try_matches()
	local teststrs = { 
		["1234"] = "number",
		["Hi"] = "word", 
		["1-10"] = "range",
		["Bye"] = "word",
		["A123"] = "nil"
	}
	
	for teststr, expected in pairs(teststrs) do
		local result = control.try_matches{teststr,
			number = "^%d+$",
			word = "^%a+$",
			range = "^%d+%-%d+$"
		}
		
		local ok
		if result == expected then
			ok = true
		elseif result == nil and expected == "nil" then
			ok = true
		end
		
		if not ok then
			error(string.format("Test string %s failed. Expected %s, but try_matches returned %s", teststr, expected, result))
		end
	end
end

function test_cycle()
	local count=0
	local desiredcount = 15
	local starttime = timer.seconds()
	
	control.cycle(desiredcount, function ()
		count = count + 1
		if timer.seconds() - starttime > 1 then
			return true
		end
	end)
	
	if count ~= desiredcount then
		error("Cycle test failed. Count = " .. count)
	end
end

