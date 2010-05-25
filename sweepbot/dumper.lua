import "config"

local task = require "cbclua.task"

local power = 40

local dump_time = 1.6
local speed = -200

function init()
	reset()
end

function reset()
	dumper_motor:setpwm(70)
	local prevpos = dumper_motor:getpos()
	while true do
		task.sleep(.01)
		local pos = dumper_motor:getpos()
		if pos - prevpos < 5 then break end
		prevpos = pos
	end
	
	dumper_motor:off()
	task.sleep(.2)
	dumper_motor:mrp(0, 1)
end

function off()
	dumper_motor:off()
end

function dump()
	dumper_motor:setpwm(-70)
	task.sleep(.5)
end
