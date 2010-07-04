local create = require "mb.create"
local task = require "cbclua.task"
local timer = require "cbclua.timer"
local sponge = require "sponge"
import "config"


function drop_sponge(chargedist, cursponge)
	print("Dropping " .. cursponge .. " sponge")
	local spongeselect = task.async(function ()
		sponge.reset()
		sponge.select(cursponge)
	end)
	
	local side
	if chargedist > 0 then
		drive:fd{inches=chargedist}
		side = drive_to_oilslick("fd")
	else
		drive:bk{inches=-chargedist}
		side = drive_to_oilslick("bk")
	end
	print("Got oil slick on side " .. side)

	if side == "timeout" then
		if chargedist > 0 then
			drive:bk{inches=4}
		else
			drive:fd{inches=4}
		end
		task.join(spongeselect)
		return
	end

	local turnamt
	local fddist = 2
	if cursponge == "small" then
		turnamt = -90
	elseif cursponge == "large" then
		turnamt = 90
		if side == "left" or side == "right" then
			fddist = fddist + 5
		else
			fddist = fddist + 3
		end
		
		if chargedist < 0 then
			fddist = fddist - 5
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
	
	print("Fddist", fddist)
	print("Turnamt", turnamt)
	if fddist > 0 then
		drive:fd{inches=fddist}
	end
	turn(turnamt)
	task.join(spongeselect)
	sponge.release()
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
	
	local start_time = timer.seconds()
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
		
		if timer.seconds() - start_time > 3 then
			cliff = "timeout"
			break
		end
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

function read_lineups()
	return left_lineup() < 400 and right_lineup() < 400
end

function read_either_lineup()
	return left_lineup() < 400 or right_lineup() < 400
end


