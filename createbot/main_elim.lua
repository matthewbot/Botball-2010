local task = require "cbclua.task"
local create = require "mb.create"
local lance = require "lance"
local scripts = require "scripts"
local main_shared = require "main_shared"
import "config"

function main()
	main_shared.init()
	
	lance_sweep()
	main_shared.dirty_ducks()
	
	drive:bk{inches=15}
	drive:rturn{degrees=80}
	wall_lineup(37)
	
	main_shared.clean_ducks()
end

function lance_sweep()
	task.async(function ()
		task.sleep(2.25)
		lance.extend()
	end)
	scripts.sweep_position:play()
	
	drive:rturn{degrees=40}
	task.sleep(1.2)
	bdrive:rturn{degrees=45, vel=9}
	bdrive:rturn{degrees=45, vel=2}
	lance.retract()
end

