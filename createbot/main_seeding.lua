local main_shared = require "main_shared"
import "main_shared"
import "config"

function main()
	init()
	dirty_ducks_se()
	
	drive:bk{inches=15}
	drive:rturn{degrees=85}
	wall_lineup(37)
	
	clean_ducks()
end

function dirty_ducks_se()
	local oilslicks = { }
	local dropped_small = false
	
	local function drop_sponge(dist, num)
		local slick = oilslicks[num]
		if slick == "none" then
			return false
		elseif slick == "small" then
			if dropped_small then
				return false
			else
				dropped_small = true
			end
		end
		algorithm.drop_sponge(dist, oilslicks[num])
		
		return true
	end
	
	oilslicks[1] = grab_dirty_ducks(20, 20)
	oilslicks[2] = grab_dirty_ducks(20, 21)
	oilslicks[3] = grab_dirty_ducks(23, 22)
	wall_lineup(9)
	
	if not drop_sponge(-36, 1) then
		drive:bk{inches=36}
	end
	
	if not drop_sponge(12, 2) then
		drive:fd{inches=24}
	end
	
	wall_lineup(15)
	drive:bk{inches=4}
	drive:rturn{degrees=90}
	bdrive:bk{vel=8, wait=create.bump}
	oilslicks[4] = grab_dirty_ducks(22, 23)
	
	if drop_sponge(-5, 3) then
		wall_lineup(20) -- wall lineup
	else
		wall_lineup(16) -- wall lineup, slightly less
	end
	drive:bk{inches=4}
	drive:rturn{degrees=90}
	
	oilslicks[5] = grab_dirty_ducks(24, 20, .5)
	
	if drop_sponge(-2, 4) then
		wall_lineup(26, true) -- line up against duck area
	else
		wall_lineup(20, true) -- line up against duck area
	end
	
	if drop_sponge(-1, 5) then
		wall_lineup(1, true)
	end
	
	claw.down_push{wait=true}
	claw.release_ground() -- release a duck possibly still in our claw
	task.sleep(.3)
	claw.up()
	task.sleep(.5)
	claw.close()
	drive:bk{inches=1}
	drive:lturn{degrees=85}
	claw.down_push{wait=true}
	claw.eject()
	task.sleep(.4)
	claw.up{wait=true}
end
	

