local tasks = require "mb.create.tasks"
local comm = require "mb.create.comm"
local util = require "cbclua.util"
local cbc = require "cbclua.cbc"
local userprgm = require "cbclua.userprgm"
local string = require "string"

export "mb.create.state" -- has left_motor, right_motor, and sensors
export "mb.create.drive" -- has Drive class

set_packet_rate = tasks.set_packet_rate
get_packet_rate = tasks.get_packet_rate -- make one function from tasks visible

--

function connect_verbose()
	while true do
		print("Connecting to create...")
		
		local connected, msg = connect()
		if connected then break end
		
		util.wait_continue("Error connecting: " .. msg)
	end
	
	print("Create connected. Bat: " .. get_battery() .. " mv")
end

function connect()
	if get_connection_state() ~= "disconnected" then return true end
	
	comm.init()
	
	local ok, msg, bat, lenc, renc = comm.send_start()
	
	if not(ok) then
		comm.quit()
		return false, msg
	end
	
	update_battery(bat)
	left_motor:set_raw_encoder(lenc)
	right_motor:set_raw_encoder(renc)
	
	tasks.start()
	
	update_connection_state("connected")
	
	return true
end

function disconnect()
	if get_connection_state() == "disconnected" then return true end

	tasks.stop()
	comm.send_stop()
	comm.quit()
	
	update_connection_state("disconnected")
	return true
end

userprgm.add_stop_hook(disconnect)

