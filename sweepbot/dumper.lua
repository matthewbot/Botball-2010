import "config"

local task = require "cbclua.task"

local dump_time = .5
local power = 70

local dumped = false

function init()
	reset()
end

function reset()
	dumper_motor:setpwm(power)
	local prevpos = dumper_motor:getpos()
	while true do
		task.sleep(.05)
		local pos = dumper_motor:getpos()
		if pos - prevpos < 3 then break end
		prevpos = pos
	end
	
	dumper_motor:off()
	task.sleep(.03)
	dumper_motor:mrp(0, 1)
	dumped = false
end

function off()
	dumper_motor:off()
end

function shake()
	local times = 0
	while times < 5 do
		dumper_motor:setpwm(-power)
		task.sleep(.05)
		dumper_motor:setpwm(power)
		task.sleep(.1)
		times = times + 1
	end
end

function dump()
	if dumped then error("Dumper has been dumped! Reset first!") end
	dumper_motor:setpwm(-power)
	task.sleep(dump_time)
	dumper_motor:off()
	dumped = true
end
