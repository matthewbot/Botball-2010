local task = require "cbclua.task"
local cbc = require "cbclua.cbc"
local algorithm = require "algorithm"
local create = require "mb.create"
local lance = require "lance"
local scripts = require "scripts"
local claw = require "claw"
import "main_shared"
import "config"

function main()
	init()
	
	local sweep_ok = lance_sweep()
	print("sweep_ok", sweep_ok)
	after_sweep_lineup(sweep_ok)
	dirty_ducks_de()
	
	clean_ducks()
end

function lance_sweep()
	print("Sweeping lance")

	task.async(function ()
		task.sleep(2.2)
		lance.extend()
	end)
	scripts.sweep_position:play()
	
	local ok = task.timeout(6, function ()
		bdrive:rturn{degrees=10, vel=8}
		task.sleep(.6)
		bdrive:rturn{degrees=45, vel=9}
		bdrive:rturn{degrees=45, vel=5}	
		lance.retract()
	end)
	
	return ok
end

function after_sweep_lineup(sweep_ok)
	drive:lpiv{vel=-8, wait=create.bump}
	drivetrain:drive(-8, 5)
	task.sleep(.4)
	task.wait_while(create.bump)
	drivetrain:drive(0, 0)
	drive:bk{vel=10, wait=create.bump}
	if not sweep_ok then
		lance.retract()
	end
	drive:lturn{degrees=80}
	drive:fd{vel=8, time=1}
	drive:lpiv{degrees=-27}
	task.sleep(1)
	
	drive:bk{inches=38}
	drive:rturn{degrees=130}
	wall_lineup(27)
	drive:bk{inches=5}
	drive:rturn{degrees=90}
	wall_lineup(3)
	drive:bk{inches=4}
	drive:rturn{degrees=90}
end

--[[
function after_sweep_lineup()
	bdrive:lturn{degrees=5}
	wall_lineup(6)
	drive:rpiv{degrees=-45}
	
	drive:bk{inches=30}
	drive:rturn{degrees=130}
	wall_lineup(28)
	drive:bk{inches=5}
	drive:rturn{degrees=90}
	wall_lineup(3)
	drive:bk{inches=4}
	drive:rturn{degrees=90}
end]]

function dirty_ducks_de()
	local oilslicks = { }
	local dropped = { }
	
	local function drop_sponge(dist, num)
		local slick = oilslicks[num]
		if slick == "none" then
			return false
		end
		
		local override_slick
		if dropped[slick] then
			if slick == "small" then
				if num == 2 then
					if oilslicks[1] ~= "medium" then
						override_slick = "medium"
					else
						override_slick = "large"
					end
				elseif num == 1 then
					if dropped["medium"] then
						override_slick = "large"
					else
						override_slick = "medium"
					end
				end
			else
				return false
			end
		else
			dropped[slick] = true
		end

		algorithm.drop_sponge(dist, override_slick or oilslicks[num])
		
		return true
	end
	
	oilslicks[1] = grab_dirty_ducks(20, 19.5, .5)
	oilslicks[2] = grab_dirty_ducks(20, 19, .2)
	oilslicks[3] = grab_dirty_ducks(21, 20)
	wall_lineup(4)
	
	drive:bk{inches=14}
	drive:lturn{degrees=180}
	
	if not drop_sponge(-2, 3) then
		drive:fd{inches=4}
	end
	if not drop_sponge(10, 2) then
		drive:fd{inches=14}
	end
	
	if not drop_sponge(10, 1) then
		drive:fd{inches=18}
	end
	
	drive:lturn{degrees=10}
	wall_lineup(30)
	drive:bk{inches=18}
	
	drive:lturn{degrees=90}
	wall_lineup(15)

	drive:bk{inches=1}
	claw.down_push{speed=900}
	drive:lturn{degrees=90}
	claw.eject()
	task.sleep(.4)
	claw.up{}

	drive:lturn{degrees=178}
	wall_lineup(18) -- possibly shorter?
end

