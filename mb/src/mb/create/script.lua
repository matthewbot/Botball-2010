local comm = require "mb.create.comm"
local tasks = require "mb.create.tasks"
local serial = require "cbclua.serial"
local bit = require "cbclua.bit"
local table = require "table"
local math = require "math"
local string = require "string"

import "mb.create.proto"
import "mb.create.state"

--

local current_script = nil
local inch_to_mm = 25.4

Script = create_class "Script"

function Script:construct(comm_entries)
	self.bytes = table.concat(comm_entries)
end

function Script:play()
	assert_connection() -- make sure we've actually got a create connection before continuing
	tasks.stop() -- turn off the tasks
	update_connection_state("script")
	
	comm.send_script_bytes(self.bytes)
	comm.play_script()
	
	update_connection_state("connected")
	tasks.start()
end

function drive_direct(lspeed, rspeed)
	return string.char(DriveDirect) .. bit.make16(rspeed) .. bit.make16(lspeed)
end

function stop()
	return drive_direct(0, 0)
end

function wait_time(secs)
	if secs > 25.5 then
		return wait_time(secs - 25.5) .. string.char(WaitTime, 255)
	else
		return string.char(WaitTime, math.floor(secs * 10))
	end
end

function wait_dist(dist)
	local mm = dist * inch_to_mm
	
	return string.char(WaitDistance) .. bit.make16(mm)
end

function wait_angle(angle)
	return string.char(WaitAngle) .. bit.make16(angle)
end
	
	
	
