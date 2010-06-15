import "config"

local compactor = require "compactor"

function main()
end

function goto_pos_dr()
	compactor.init()
	drive:fd{inches = 27.5}
	drive:rturn{degrees = 90}
	drive:fd{inches = 49.2}
	drive:rturn{degrees = 90}
end