local main_shared = require "main_shared"
local algorithm = require "algorithm"
local create = require "mb.create"
local task = require "cbclua.task"
local botball = require "cbclua.botball"
local claw = require "claw"
import "main_shared"
import "config"

function main()
	init()
	botball.start(starting_light)
	task.sleep(3)
	dirty_ducks_se()
	
	drive:bk{inches=13}
	drive:rturn{degrees=85}
	wall_lineup(45)
	
	clean_ducks()
end

function dirty_ducks_se()
	local oilslicks = { }
	local dropped = { }
	
	local function drop_sponge(dist, num)
		local slick = oilslicks[num]
		if slick == "none" then
			return false
		end
		
		if dropped[slick] then
			return false
		else
			dropped[slick] = true
		end

		algorithm.drop_sponge(dist, oilslicks[num])
		
		return true
	end
	
	oilslicks[1] = grab_dirty_ducks(20, 19.5, .5)
	oilslicks[2] = grab_dirty_ducks(20, 19, .2)
	oilslicks[3] = grab_dirty_ducks(21, 20)
	task.sleep(1)
	wall_lineup(7)
	
	if not drop_sponge(-36, 1) then
		drive:bk{inches=36}
	end
	
	if not drop_sponge(12, 2) then
		drive:fd{inches=24}
	end
	
	wall_lineup(5)
	drive:bk{inches=4}
	drive:rturn{degrees=90}
	bdrive:bk{vel=8, wait=create.bump}
	drive:fd{inches=5}
	task.sleep(1) -- maybe not needed
	oilslicks[4] = grab_dirty_ducks(14, 12, .5)
	task.sleep(.5)
	
	if drop_sponge(-5, 3) then
		wall_lineup(10) -- wall lineup
	else
		wall_lineup(8) -- wall lineup, slightly less
	end
	drive:bk{inches=6}
	drive:rturn{degrees=90}
	
	oilslicks[5] = grab_dirty_ducks(24, 20, .5)
	task.sleep(.5)
	
	if drop_sponge(-5, 4) then
		wall_lineup(27, true) -- line up against duck area
	else
		wall_lineup(18, true) -- line up against duck area
	end
	
	if drop_sponge(-1, 5) then
		wall_lineup(1, true)
	end
	
	drive:bk{inches=1}
	claw.down_push{speed=900}
	drive:lturn{degrees=85}
	claw.eject()
	task.sleep(.2)
	claw.up()
end
	

