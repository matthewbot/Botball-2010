local task = require "cbclua.task"
local create = require "mb.create"
local lance = require "lance"
local scripts = require "scripts"
import "config"

function main()
	create.connect_verbose()
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
