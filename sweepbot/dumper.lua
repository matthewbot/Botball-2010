import "config"

local power = 40

local dumping_pos = -485
local speed = 200

function init() dumper:setpwm(power) end

function dumper_dump() dumper:mrp(speed, dumping_pos) end
