local task = require "cbclua.task"
local create = require "mb.create"
local lance = require "lance"
local scripts = require "scripts"
import "config"


function main()
	create.connect_verbose()
	task.async(lance.extend)
	scripts.sweep_position:play()
	
	bdrive:rturn{degrees=45, vel=9}
	bdrive:rturn{degrees=45, vel=3}
	lance.retract()
end

