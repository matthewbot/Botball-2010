import "config"

local task = require "cbclua.task"
local math = require "math"
local compactor = require "compactor"
local grabs = require "grabs"
local motion = require "motion"

--Scenario A
function goto_pvc_island(last_dist)
	motion.drive_sensor("right", "fd", "pvc", 800, 500)-- before 550
	drive:fd{inches = 2}
	drive:rturn{degrees = 45}
	drive:fd{inches = last_dist}--24 inches to hit pvc of the island
	

	--[[drive:fd{inches = 29.5}
	drive:rturn{degrees = 92}
	drive:fd{inches = 49.2}]]--hit pvc of the island
end

function grab_our_leg()
	grabs.tribbles_pvc_bk(0.32)
	drive:bk{inches = 2}
	drive:rturn{degrees = 87}
	compactor.open()
	drive:scooch{xdist = -0.75}
	motion.drive_sensor("right", "fd", "pvc", 650, 600)
	drive:fd{inches = 7}
	grabs.tribbles_pvc()
end

function go_into_middle()  --middle = no touch zone
	drive:lpiv{degrees = -30}
	drive:rpiv{degrees = 37}
	drive:scooch{xdist = 0.75, dir = "bk"}
	grabs.tribbles() --to stay or not to stay?
	drive:scooch{xdist = 0.5}
	
	compactor.open()
	motion.drive_sensor("left", "fd", "pvc", 650, 500)
	drive:fd{inches = 14}
	grabs.tribbles_pvc_full()
end

function go_home()
	motion.drive_sensor("left", "bk", "pvc", 900, 500)
	drive:bk{inches = 13}
	drive:rpiv{degrees = 37}
	drive:lpiv{degrees = -30}
	
	motion.drive_sensor("left", "fd", "no_pvc", 900, 500)
	drive:fd{inches = 1}
	drive:lturn{degrees = 85}
	motion.drive_sensor("left", "fd", "pvc", 900, 400)
	motion.drive_sensor("left", "fd", "no_pvc", 900, 350)
	drive:fd{inches = 1}
	drive:lturn{degrees = 91}
	drive:fd{inches = 39}
	grabs.release()
end

--Scenario C
function block(dist)
	goto_pvc_island(22)--22 inches to get close to the pvc of the island

	drive:rturn{degrees = 90}
	compactor.close()
	compactor.extend_full()
	
	dist = dist or 0
	if dist < 0 then
		drive:bk{inches = math.abs(dist)}
	else
		drive:fd{inches = dist}
	end
	
	door_servo:disable()
end
