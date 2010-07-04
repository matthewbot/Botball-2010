local task = require "cbclua.task"
import "config"

local quad_dist = 236
local pluck_extra = 130

local sponge_table = { large=1, medium=2, small=3 }

function select(sponge)
	select_quad(sponge_table[sponge])
end

function select_quad(quad)
	sponge_motor:mtp(400, quad*quad_dist + pluck_extra)
	task.sleep(.1)
	sponge_motor:wait()
	sponge_motor:off()
end

function release()
	sponge_motor:mrp(400, -270)
	task.sleep(.1)
	sponge_motor:wait()
end

function reset()
	if sponge_reset() then
		sponge_motor:mrp(400, -100)
		sponge_motor:wait()
	end
	sponge_motor:mav(200)
	task.wait(sponge_reset)
	sponge_motor:off()
	sponge_motor:clearpos()
end

