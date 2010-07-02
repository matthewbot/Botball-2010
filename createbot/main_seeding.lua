local main_shared = require "main_shared"
import "main_shared"
import "config"

function main()
	init()
	dirty_ducks()
	
	drive:bk{inches=15}
	drive:rturn{degrees=85}
	wall_lineup(37)
	
	clean_ducks()
end

