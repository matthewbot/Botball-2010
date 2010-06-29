local create = require "mb.create"
local task = require "cbclua.task"
import "config"

function read_cliffs()
	local frontleft = create.front_left_cliff()
	local frontright = create.front_right_cliff()
	
	if frontleft < 250 and frontright < 250 then
		return "center"
	elseif frontleft < 150 then
		return "center-right"
	elseif frontright < 150 then
		return "center-left"
	elseif create.right_cliff() < 150 then
		return "left"
	elseif create.left_cliff() < 150 then
		return "right"
	end
end

function drive_to_oilslick(dir)
	if dir == "bk" then
		drive:bk{vel=5}
	else
		drive:fd{vel=5}
	end
	
	local cliff
	while true do
		cliff = read_cliffs()
		if cliff == "center-left" or cliff == "center-right" then	
			task.sleep(.25)
			cliff = read_cliffs() or "center" -- if we go past it, assume center
			break
		elseif cliff ~= nil then
			break
		end

		task.sleep(.01)
	end

	drive:stop{}
	return cliff
end
