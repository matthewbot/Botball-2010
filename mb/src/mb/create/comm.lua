local task = require "cbclua.task"
local bit = require "cbclua.bit"
local serial = require "cbclua.serial"
local string = require "string"
local math = require "math"

import "mb.create.proto"

-- Private state & constants

local port -- holds SerialPort if we have it
local led_color = 30
local led_brightness = 255

function init()
	if port ~= nil then return end
	port = serial.SerialPort()
end

function quit()
	if port == nil then return end
	port:close()
	port = nil
end

function send_start()
	port:write(Start)
	task.yield()
	port:clear()
	
	port:write(
		Full,
		LEDs, Advance + Play, led_color, led_brightness,
		QueryList, 4,
			OIMode,
			Voltage,
			LeftEncoder,
			RightEncoder
	)
	
	if not(port:wait(7, .2)) then
		return false, "timeout (" .. port:get_avail() .. ")"
	end
	
	local response = port:read(7)
	local header = response:byte(1)
	
	if header ~= 3 then
		return false, "bad header (" .. header .. ")"
	end
	
	local bat = bit.getu16(response, 2)
	local lenc = bit.getu16(response, 4)
	local renc = bit.getu16(response, 6)
	
	return true, "", bat, lenc, renc
end

function send_stop()
	port:write(Start) -- kind of ironic, but this puts the create in passive mode, shutting off motors and LEDs
end

local lastlspeed, lastrspeed = 0, 0

function send_motors(lspeed, rspeed, force)
	lspeed = math.floor(lspeed)
	rspeed = math.floor(rspeed)
	if force or lastlspeed ~= lspeed or lastrspeed ~= rspeed then
		port:write(string.char(DriveDirect) .. bit.make16(rspeed) .. bit.make16(lspeed))
		lastlspeed = lspeed
		lastrspeed = rspeed
	end
end

-- Script stuff

function send_script_bytes(bytes)
	assert(#bytes <= 100, "Script cannot exceed 100 bytes!")
	port:write(Script, #bytes)
	port:write(bytes)
end

function play_script()
	port:write(
		LEDs, 0, led_color, led_brightness,
		PlayScript
	)
	
	task.sleep(.5)
	port:clear()
	
	port:write(Sensors, OIMode) -- This is to wait until the script ends
	
	local header = port:read(1):byte(1)
	if header ~= 3 then
		error("Bad script termination header " .. header .. " avail " .. port:get_avail())
	end
	
	port:write(LEDs, Advance + Play, led_color, led_brightness)
	
	task.yield()
	port:clear()
end

function send_song_bytes(bytes)
	port:write(Song, 1)
	port:write(bytes)
end

function play_song()
	port:write(PlaySong, 1)
end

-- Update stuff

local update_response_size = 20
function send_update_request()
	port:write(
		QueryList, 13,
			ZeroSensorByteA, -- header
			ZeroSensorByteA,
			OIMode,
			OIMode,
			LeftEncoder,
			RightEncoder,
			CliffLeftSignal,
			CliffFrontLeftSignal,
			CliffFrontRightSignal,
			CliffRightSignal,
			WallSignal,
			BumpsAndWheelDrops,
			OIMode
	)
end

function receive_update()
	local got
	while true do
		got = port:read(update_response_size)
		local a, b, c, d = got:byte(1, 4)
		if a == 0 and b == 0 and c == 3 and d == 3 and got:byte(20) == 3 then
			break
		end
		port:unread(got:sub(2)) -- unread all data after the first byte
	end
	
	local data = got:sub(5) -- data begins at 5th byte
	local bumpdata = data:byte(15)
	local sensors = {
		left_bump         = bit.get(bumpdata, BumpLeft),
		right_bump        = bit.get(bumpdata, BumpRight),
		left_wheel_drop   = bit.get(bumpdata, WheeldropLeft),
		right_wheel_drop  = bit.get(bumpdata, WheeldropRight),
		front_wheel_drop  = bit.get(bumpdata, WheeldropCaster),
		left_cliff        = bit.getu16(data, 5),
		front_left_cliff  = bit.getu16(data, 7),
		front_right_cliff = bit.getu16(data, 9),
		right_cliff       = bit.getu16(data, 11),
		wall              = bit.getu16(data, 13)
	}
	
	local lenc = bit.getu16(data, 1)
	local renc = bit.getu16(data, 3)
	
	return sensors, lenc, renc
end
