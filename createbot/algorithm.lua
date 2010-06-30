local create = require "mb.create"
local task = require "cbclua.task"
import "config"


function drop_sponge(chargedist, cursponge)
	print("Dropping " .. cursponge .. " sponge")
	task.async(sponge.select, cursponge)
	
	local side
	if chargedist > 0 then
		drive:fd{inches=chargedist}
		side = algorithm.drive_to_oilslick("fd")
	else
		drive:bk{inches=-chargedist}
		side = algorithm.drive_to_oilslick("bk")
	end
	print("Got oil slick on side " .. side)

	local turnamt
	local fddist = 2
	if cursponge == "small" then
		turnamt = -90
	elseif cursponge == "large" then
		turnamt = 90
		if side == "left" then
			side = "center-left"
			fddist = fddist + 5
		elseif side == "right" then
			side = "center-right"
			fddist = fddist + 5
		else
			fddist = fddist + 3
		end
		
		if chargedist < 0 then
			fddist = fddist - 3
		end
	else
		turnamt = 0
		fddist = fddist + 1
		
		if chargedist < 0 then
			fddist = fddist - 1
		end
	end
	
	if side == "center-left" then
		turnamt = turnamt - 7
	elseif side == "center-right" then
		turnamt = turnamt + 7
	elseif side == "left" then
		turnamt = turnamt - 40
		fddist = fddist + 2
	elseif side == "right" then
		turnamt = turnamt + 40
		fddist = fddist + 2
	end
	
	print("Turnamt", turnamt)
	print("Fddist", fddist)
	if fddist > 0 then
		drive:fd{inches=fddist}
	end
	turn(turnamt)
	sponge.release()
	task.async(sponge.reset)
	task.sleep(.5)
	turn(-turnamt)
end

function turn(amt)
	if amt > 0 then
		drive:lturn{degrees=amt}
	elseif amt < 0 then
		drive:rturn{degrees=-amt}
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


