module(...)

local drive = require 'mb.drive'
local cbc = require 'std.cbc'
local task = require 'std.task'
local util = require 'std.util'
local math = require 'math'

Drive = create_class("Drive", drive.DriveBase)

-- Config functions --

local function getarg(args, name, depth)
	local val = args[name]
	if val ~= nil then return val end
	
	error("Missing argument '" .. name .. "' to bemf.Drive constructor", depth+1)
end

function Drive:construct(args)
	self.lmot = { obj = getarg(args, "lmot", 3) }
	self.rmot = { obj = getarg(args, "rmot", 3) }
	self.wb = getarg(args, "wb", 3)
	
	local topspeed = (args.topspeed or 1000) / 1000
	
	if args.dist then
		local ldata, rdata = self:parse_dir(args, topspeed) -- parse direction information from top level
		
		self.lmot.fd = ldata -- and use it for both the forward and backward settings
		self.lmot.bk = ldata
		self.rmot.fd = rdata
		self.rmot.bk = rdata
	else
		self.lmot.fd, self.rmot.fd = self:parse_dir(args.fd, topspeed) -- parse seperate direction information for forward and backward
		self.lmot.bk, self.rmot.bk = self:parse_dir(args.bk, topspeed)
	end
	
	
	self.lmot.enc = 0
	self.rmot.enc = 0
	self.encoder_signal = task.Signal()
	self.encoder_taskid = task.start(util.bind(self, "encoder_task"), "bemf.Drive encoder update", true)
end
		
function Drive:parse_dir(args, topspeed)
	local ldist = getarg(args, "dist", 4)
	
	local rmult = getarg(args, "rmult", 4)
	local rdist = ldist * rmult
 
	local ldata = { dist = ldist }
	local rdata = { dist = rdist }
	
	if ldist > rdist then
		ldata.speed = topspeed
		rdata.speed = topspeed * rdist / ldist
	else
		ldata.speed = topspeed * ldist / rdist
		rdata.speed = topspeed
	end
	
	return ldata, rdata
end

-- Raw driving functions

function Drive:get_wheelbase()
	return self.wb
end

function Drive:drive(lspeed, rspeed)
	local lmotdir, rmotdir = self:pick_dirs(lspeed, rspeed)
	local lmot, rmot = self:get_mot_objs()
	
	lmot:mav(lmotdir.speed * lspeed)
	rmot:mav(lmotdir.speed * rspeed)
end

function Drive:drive_dist(lspeed, ldist, rspeed)
	local rdist 
	
	if lspeed ~= 0 then
		if rspeed ~= 0 then
			rdist = ldist / lspeed * rspeed -- calculate rdist
		else
			rdist = 0
		end
	else
		rdist = ldist
		ldist = 0
	end
	
	local lmotdir, rmotdir = self:pick_dirs(lspeed, rspeed)
	local lmot, rmot = self:get_mot_objs()
	
	ldist = ldist * lmotdir.dist
	rdist = rdist * rmotdir.dist
	
	local lstart = lmot:getpos()
	local rstart = rmot:getpos()
	
	if lspeed ~= 0 then
		lmot:mrp(lspeed, ldist)
	end
	
	if rspeed ~= 0 then
		rmot:mrp(rspeed, rdist)
	end
	
	task.wait(function ()
		if lspeed ~= 0 then
			if lmot:getdone() then
				return true
			elseif math.abs((lmot:getpos()-lstart) - ldist) < 10 then
				return true
			end
		end
		
		if rspeed ~= 0 then
			if rmot:getdone() then
				return true
			elseif math.abs((rmot:getpos()-rstart) - rdist) < 10 then
				return true
			end
		end
	end) 
	
	lmot:off()
	rmot:off()
end
	
function Drive:pick_dirs(lspeed, rspeed)
	local lmotdir = lspeed > 0 and self.lmot.fd or self.lmot.bk -- chose the left and right motor settings based on the speed
	local rmotdir = rspeed > 0 and self.rmot.fd or self.rmot.bk
	
	return lmotdir, rmotdir
end

function Drive:get_mot_objs()
	return self.lmot.obj, self.rmot.obj
end

function Drive:stop()
	self.lmot.obj:off()
	self.rmot.obj:off()
end

function Drive:encoder_task()
	local lmot = self.lmot
	local rmot = self.rmot
	
	local lprev, rprev = lmot.obj:getpos(), rmot.obj:getpos()

	while true do
		task.sleep(.25)
		
		local l, r = lmot.obj:getpos(), rmot.obj:getpos()
		local dl, dr = l - lprev, r - rprev
		
		if dl > 0 then
			lmot.enc = lmot.enc + dl / lmot.fd.dist
		elseif dl < 0 then
			lmot.enc = lmot.enc + dl / lmot.bk.dist -- dl is negative
		end
		
		if dr > 0 then
			rmot.enc = rmot.enc + dr / rmot.fd.dist
		elseif dr < 0 then
			rmot.enc = rmot.enc + dr / rmot.bk.dist -- dr is negative
		end
		
		lprev, rprev = l, r
		self.encoder_signal:notify()
	end
end	

function Drive:read_encoders()
	return self.lmot.enc, self.rmot.enc
end

function Drive:wait_encoders()
	self.encoder_signal:wait()
end
