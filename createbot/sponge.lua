import "config"

local quad_dist = 236
local pluck_dist = 50
local current_quad = 4

local sponge_table = { large=1, medium=3, small=2 }

function select(sponge)
	select_quad(sponge_table[sponge])
end

function select_quad(quad)
	local dist = quad - current_quad
	if dist < 0 then
		dist = dist + 4
	end
	current_quad = quad
	
	print(dist * quad_dist)
	sponge_motor:mrp(400, dist * quad_dist)
	sponge_motor:wait()
	sponge_motor:off()
end

function release()
	sponge_motor:mrp(400, pluck_dist)
	sponge_motor:wait()
	sponge_motor:mrp(400, -pluck_dist * 2)
	sponge_motor:wait()
	sponge_motor:mrp(400, pluck_dist)
	sponge_motor:wait()
	sponge_motor:off()
end

