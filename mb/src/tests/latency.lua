local cbc = require "cbclua.cbc"
local task = require "cbclua.task"
local timer = require "cbclua.timer"
local math = require "math"

function test(func, cycles)
	local prevtime = timer.seconds()
	while true do
		local max = 0
		local avg = 0
		for i=1,cycles do
			func()
			local curtime = timer.seconds()
			local val = curtime - prevtime
			
			avg = avg + val
			if val > max then
				max = val
			end
			
			prevtime = curtime
		end
		print(math.round(max, 4), math.round(avg/cycles, 4))
	end	
end

function sleeptest(amt)
	test(function ()
		task.sleep(amt)
	end, 10)
end

function bobtest()
	local sensor = cbc.AnalogSensor{0}
	test(function ()
		sensor:read()
	end, 50)
end
