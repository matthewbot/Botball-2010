import "config"

local task = require "cbclua.task"
local compactor = require "compactor"

function main()
	compactor.init()
	drive:fd{inches = 29.5}
	drive:rturn{degrees = 92}
	drive:fd{inches = 49.2}--hit pvc of the island
	
	compactor.pvc_grap()
	drive:bk{inches = 2}
	drive:rturn{degrees = 90}
	compactor.open()
	drive:scooch{xdist = -0.5}
	drive_sensor("right", "fd", 632)
	drive:fd{inches = 7}
	compactor.close_half()
	compactor.close()

	--scenario B:not going into the middle
	
	--scenario A:going into the middle
	drive:lpiv{degrees = -30}
	drive:rpiv{degrees = 37}
	drive:scooch{xdist = 0.75, dir = "bk"}
	drive:scooch{xdist = 0.5}
	compactor.open()
	drive_sensor("left", "fd", 632)
	drive:fd{inches = 12}
	
end

function mid_prog()
	drive:lpiv{degrees = -30}
	drive:rpiv{degrees = 37}
	drive:scooch{xdist = 0.75, dir = "bk"}
	drive:scooch{xdist = 0.5}
	compactor.open()
	drive_sensor("left", "fd", 632)	
end

function drive_sensor(side, dir, value) --need to add speed value
	if side == "left" then
		if dir == "fd" then
			drive:fd{speed = 630}
		elseif dir == "bk" then
			drive:bk{speed = 630}
		end
		task.wait(function () return lrange() > value end)
		drive:off{}
	elseif side == "right" then
		if dir == "fd" then
			drive:fd{speed = 630}
		elseif dir == "bk" then
			drive:bk{speed = 630}
		end
		task.wait(function () return rrange() > value end)
		drive:off{}
	end
end

function goto_pos_dr()
	compactor.init()
	drive:fd{inches = 29.5}
	drive:rturn{degrees = 90}
	drive:fd{inches = 49.2}
	drive:rturn{degrees = 90}
end