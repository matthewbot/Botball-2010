local task = require "cbclua.task"
local timer = require "cbclua.timer"
local table = require "table"

function time_sequence(timeline)
	local starttime = timer.seconds()

	for _, entry in ipairs(timeline) do
		local time = starttime + entry[1]
		local func = entry[2]
		
		task.sleep_till(time)
		func(unpack(entry, 3))
	end
end

function try_matches(entries)
	local str = assert(entries[1], "Missing string in first argument to try_matches")
	entries[1] = nil
	
	for name, pattern in pairs(entries) do
		local matches = { str:match(pattern) }
		if matches[1] ~= nil then
			return name, matches
		end
	end
end

function cycle(hertz, func)
    local starttime = timer.seconds()
	while true do
		local prevtime = timer.seconds()
		local val = func(prevtime - starttime)
		
		if val ~= nil then
			return val
		end
		
		local delaytime = 1/hertz - (timer.seconds() - prevtime)
		if delaytime > 0 then
			task.sleep(delaytime)
		else
			task.yield()
		end
	end
end

