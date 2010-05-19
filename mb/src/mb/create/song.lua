local comm = require "mb.create.comm"
local task = require "cbclua.task"
local math = require "math"
local string = require "string"

import "mb.create.state"
Song = create_class "mb.create.song.Song"

local notenums = { G=1, A=3, B=5, C=6, D=8, E=10, F=11 }

function Song:construct(bpm, str)
	if str == nil then
		str = bpm
		bpm = 120
	end
	
	local bps = bpm / 60
	local bytes = ""
	
	local notecount = 0
	local totalduration = 0
	
	for length, name, sharp, octave in str:gmatch("(%d+)%s-(%w)(#?b?)(%d?)") do
		local notenum 
		
		if name == "r" or name == "R" then
			notenum = 0
		else 
			notenum = 30 + (octave-1)*12 + notenums[name:upper()]
		
			if sharp == "#" then
				notenum = notenum + 1
			elseif sharp == "b" then
				notenum = notenum - 1
			end
		end
		
		local noteduration = (1/length) * 4 / bps
		local notelen = math.floor( noteduration / (1/64) + .5)
		
		bytes = bytes .. string.char(notenum, notelen)
		
		notecount = notecount + 1
		totalduration = totalduration + noteduration
	end
	
	if notecount > 16 then
		error("Can't have more than 16 notes in a song", 2)
	end
	
	self.bytes = string.char(notecount) .. bytes -- prepend length of song
	self.notecount = notecount
	self.duration = totalduration
end

function Song:play()
	assert_connection()

	comm.send_song_bytes(self.bytes)
	comm.play_song()
	task.sleep(self.duration)
end

function Song:get_duration()
	return self.duration
end

function Song:get_note_count()
	return self.notecount
end
	
