import "config"

local task = require "cbclua.task"

local dump_time = .5
local power = 70

local dumped = false

function init()								-- initializes the dumper
	reset()
end

function reset()							-- resets the dumper (up position)
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

function reset_check()								-- does a reset, but checks to see if it is stuck (if botguy is stuck in the dumper, it will remain down, but return false to reset)
	dumper_motor:setpwm(power)
	local prevpos = dumper_motor:getpos()
	local checkpos = prevpos
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
	
	local pos = dumper_motor:getpos()
	if pos - checkpos < 100 then
		return false
	else
		return true
	end
end	

function off()									-- cuts dumper
	dumper_motor:off()
end

function shake()						-- shakes dumper to get botguy in place
	local times = 0
	while times < 5 do
		dumper_motor:setpwm(-power)
		task.sleep(.05)
		dumper_motor:setpwm(power)
		task.sleep(.1)
		times = times + 1
	end
end

function dump()							-- dumps botguy
	if dumped then error("Dumper has been dumped! Reset first!") end
	dumper_motor:setpwm(-power)
	task.sleep(dump_time)
	dumper_motor:off()
	dumped = true
end
