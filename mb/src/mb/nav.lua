local math = require "math"
local table = require "table"
local string = require "string"

-- Predeclared functions & constants

local wrap_turn
local find_best_motion
local make_motions

local pi = math.pi
local twopi = 2*pi

-- Classes

Navigator = create_class "Navigator"
local NavMotion = create_class "NavMotion"

-- Implementation

function Navigator:construct(args)
	self.odom = assert(args.odom, "Missing odom argument to Navigator constructor")
	self.turn_speed = args.turn_speed or 1000
	self.drive_speed = args.drive_speed or 1000
end

function Navigator:go(args)
	local odom = self.odom
	local dx = assert(args.x, "go missing x argument") - odom:get_x()
	local dy = assert(args.y, "go missing y argument") - odom:get_y()

	local travel_dir = math.atan2(dy, dx)
	local travel_dist = math.sqrt(dx^2 + dy^2)
	
	local face_dir
	if args.face_dir then
		face_dir = math.rad(args.face_dir)
	end
		
	local motions = make_motions(odom:get_dir_rad(), travel_dir, travel_dist, face_dir, args)
	local bestmotion = find_best_motion(motions)
	
	bestmotion:exec(args.drive or odom:get_drive(), args.drive_speed or self.drive_speed, args.turn_speed or self.turn_speed)
end
		
function Navigator:face(args)
	local odom = self.odom
	local heading
	
	if args.dir then
		heading = math.rad(args.dir)
	elseif args.rad then
		heading = args.rad
	elseif args.x and args.y then
		heading = math.atan2(args.y - odom:get_y(), args.x - odom:get_x())
	else
		error("Missing arguments to Navigation:face, need dir, rad, or x and y", 2)
	end
	
	local turn = args.turn
	local dir = heading - odom:get_dir_rad()
	
	if turn == nil or turn == "both" then
		while dir > pi do
			dir = dir - twopi
		end
		while dir < -pi do
			dir = dir + twopi
		end
	else
		dir = wrap_turn(dir, turn)
	end
	
	local drive = args.drive or odom:get_drive()
	drive:lturn{ radians = dir, speed = args.turn_speed or self.turn_speed }
end	

--

function find_best_motion(motions)
	local best = nil

	for _, motion in ipairs(motions) do
		if best == nil or motion:get_turn_dist() < best:get_turn_dist() then
			best = motion
		end
	end
	
	return best
end

function make_motions(current_dir, travel_dir, travel_dist, face_dir, props)
	local travel_turn = props.travel_turn or "both"
	local travel_fdbk = props.travel_fdbk or "both"
	local face_turn = props.face_turn or "both"

	local motions = { }

	local function make_turn_fdbk_face(travel_turn, travel_fdbk, face_turn)
		table.insert(motions, NavMotion(current_dir, travel_dir, travel_dist, face_dir, travel_fdbk, travel_turn, face_turn))
	end

	local function make_turn_fdbk(travel_turn, travel_fdbk)
		if face_dir == nil then
			make_turn_fdbk_face(travel_turn, travel_fdbk, nil)
		else
			if face_turn == "both" or face_turn == "left" then
				make_turn_fdbk_face(travel_turn, travel_fdbk, "left")
			end
		
			if face_turn == "both" or face_turn == "right" then
				make_turn_fdbk_face(travel_turn, travel_fdbk, "right")
			end
		end
	end
	
	local function make_turn(travel_turn)
		if travel_fdbk == "both" or travel_fdbk == "fd" then
			make_turn_fdbk(travel_turn, "fd")
		end
		
		if travel_fdbk == "both" or travel_fdbk == "bk" then
			make_turn_fdbk(travel_turn, "bk")
		end
	end

	if travel_turn == "both" or travel_turn == "left" then	
		make_turn("left")
	end
	
	if travel_turn == "both" or travel_turn == "right" then
		make_turn("right")
	end
	
	return motions
end

--

function NavMotion:construct(current_dir, travel_dir, travel_dist, face_dir, travel_fdbk, travel_turn, face_turn)
	if travel_fdbk == "fd" then
		self.travel_dist = travel_dist
	else
		self.travel_dist = -travel_dist
		travel_dir = travel_dir + pi
	end

	self.travel_turn = wrap_turn(travel_dir - current_dir, travel_turn)
	if face_dir ~= nil then
		self.face_turn = wrap_turn(face_dir - travel_dir, face_turn)
	else
		self.face_turn = 0
	end
end

function NavMotion:get_turn_dist()
	if self.turn_dist then
		return self.turn_dist
	end
	
	local turn_dist = math.abs(self.travel_turn) + math.abs(self.face_turn)
	self.turn_dist = turn_dist
	return turn_dist
end

function NavMotion:exec(drive, drive_speed, turn_speed)
	if self.travel_turn ~= 0 then
--		print("Turning " .. math.deg(self.travel_turn))
		drive:lturn{radians = self.travel_turn, speed = turn_speed}
	end
	
	if self.travel_dist ~= 0 then
--		print("Traveling " .. self.travel_dist)
		drive:fd{inches = self.travel_dist, speed = drive_speed}
	end
	
	if self.face_turn ~= 0 then
--		print("Face turn " .. math.deg(self.face_turn))
		drive:lturn{radians = self.face_turn, speed = turn_speed}
	end
end

function NavMotion:__tostring()
	return string.format("Turn %f Travel %f Face %f", self.travel_turn, self.travel_dist, self.face_turn)
end

--

function wrap_turn(turn, dir)
	if dir == "left" then -- if the turn should be left
		while turn < 0 do -- and its right
			turn = turn + twopi -- make it into a large left turn
		end
	else -- if the turn should be right
		while turn > 0 do	-- and its left
			turn = turn - twopi -- make it into a large right
		end
	end
	
	while turn <= -twopi do -- Remove 360s so the robot doesn't look like a tard
		turn = turn + twopi
	end
	while turn >= twopi do 
		turn = turn - twopi 
	end
	
	return turn
end
