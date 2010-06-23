import "config"

local task = require "cbclua.task"
local compactor = require "compactor"

function main()
	compactor.init()
	task.sleep(3.0)
	compactor.capture("tribbles")
	task.sleep(.5)
	compactor.release()
end

function goto_pos_dr()
	compactor.init()
	drive:fd{inches = 27.5}
	drive:rturn{degrees = 90}
	drive:fd{inches = 49.2}
	drive:rturn{degrees = 90}
end