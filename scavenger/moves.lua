import "config"

local task = require "cbclua.task"
local math = require "math"
local compactor = require "compactor"
local grabs = require "grabs"
local motion = require "motion"

--Scenario A
function goto_pvc_island()
	motion.drive_sensor("right", "fd", "pvc", 800, 550)
	drive:fd{inches = 2}
	drive:rturn{degrees = 45}
	drive:fd{inches = 24}--hit pvc of the island
	

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
	grabs.tribbles() --to stay or not to stay?
	drive:scooch{xdist = 0.75, dir = "bk"}
	drive:scooch{xdist = 0.5}
	compactor.open()
	motion.drive_sensor("left", "fd", "pvc", 650, 500)
	drive:fd{inches = 14}
	grabs.tribbles_pvc()
	task.sleep(1)
	compactor.extend(0.5)
end

function go_home()
	--grabs.tribbles_pvc()
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
	motion.drive_sensor("right", "fd", "pvc", 800, 520)
	drive:fd{inches = 2}
	drive:rturn{degrees = 45}
	drive:fd{inches = 22}--hit pvc of the island

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
