import "config"

local task = require "cbclua.task"
local compactor = require "compactor"
local motion = require "motion"

--Scenario A
function goto_pvc_island()
	drive:fd{inches = 29.5}
	drive:rturn{degrees = 92}
	drive:fd{inches = 49.2}--hit pvc of the island
end

function grap_our_leg()
	compactor.pvc_grap()
	drive:bk{inches = 2}
	drive:rturn{degrees = 90}
	compactor.open()
	drive:scooch{xdist = -0.5}
	motion.drive_sensor("right", "fd", 650, 632)
	drive:fd{inches = 7}
	compactor.close_half()
	compactor.close()
end

function go_into_middle()  --middle = no touch zone
	drive:lpiv{degrees = -30}
	drive:rpiv{degrees = 37}
	drive:scooch{xdist = 0.75, dir = "bk"}
	drive:scooch{xdist = 0.5}
	compactor.open()
	motion.drive_sensor("left", "fd", 650, 632)
	drive:fd{inches = 12}
end

