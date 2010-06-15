local cbc 			= require "cbclua.cbc"
local vision 		= require "cbclua.vision"
local servoutils 	= require "mb.servoutils"
local motorutils 	= require "mb.motorutils"
local drivemod      = require "mb.drive"

------------
-- Motors --
------------

ldrive 	= motorutils.FixMotor{3}
rdrive 	= motorutils.FixMotor{0}

extend_motor = motorutils.FixMotor{2}

sdrivetrain = drivemod.MotorDriveTrain{
	lmot = ldrive,
	rmot = rdrive,
	ticks = 97,
	rmult = 1.01,
	wb = 7.3
}
sdrive = drivemod.Drive{
	drivetrain = sdrivetrain,
	style = drivemod.Smooth{accel=15},
	topvel = 8,
}

--[[
bdrivetrain = drivemod.MotorDriveTrain{
	lmot = ldrive,
	rmot = rdrive,
	ticks = 97,
	rmult = .99,
	wb = 7.3
}
bdrive = drivemod.Drive{
	drivetrain = bdrivetrain,
	style = drivemod.BangBang(),
	topvel = 8,
	topvel_turn = 1.9
}
]]--


------------
-- Servos --
------------

door_servo 	= servoutils.RescaleServo{1, start_pos = 400, end_pos = 1350}

------------
-- Vision --
------------

-------------
-- Sensors --
-------------

out_sensor = cbc.DigitalSensor{8}
in_sensor = cbc.DigitalSensor{9}