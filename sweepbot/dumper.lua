import "config"

local task = require "cbclua.task"

local power = 40

local dump_time = 1.6
local speed = -200

function init()
	dumper_motor:mrp(0, 1)
end

function off()
	dumper_motor:off()
end

function dump()
	dumper_motor:mav(speed)
	task.sleep(dump_time)
	dumper_motor:off()
	dumper_motor:mav(-speed)
	task.sleep(dump_time)
	dumper_motor:off()
end

function reset()
	dumper_motor:mav(-speed)
	task.sleep(dump_time)
	dumper_motor:off()
end