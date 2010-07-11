local cbc 			= require "cbclua.cbc"
local vision        = require "mb.vision"
local servoutils 	= require "mb.servoutils"
local motorutils 	= require "mb.motorutils"
local drivemod      = require "mb.drive"

------------
-- Motors --
------------

ldrive 	= motorutils.FixMotor{2}
rdrive 	= motorutils.FixMotor{0}

extend_motor = motorutils.FixMotor{1}

drivetrain = drivemod.MotorDriveTrain{
	lmot = ldrive,
	rmot = rdrive,
	ticks = 97,
	rmult = 1.01,
	wb = 7.3
}
drive = drivemod.Drive{
	drivetrain = drivetrain,
	style = drivemod.Smooth{accel=8},
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

door_servo 	= servoutils.RescaleServo{3, start_pos = 250, end_pos = 1350}

------------
-- Vision --
------------

cm_green = vision.ColorModel{
	lefthue = 88,
	righthue = 156,
	minsat = 100,
	minval = 100
}
cm_red = vision.ColorModel{
	lefthue = 0,
	righthue = 15,
	minsat = 110,
	minval = 80,
	--maxval = 200
}
gip = vision.GridImageProcessor(8, 5)
gip:addColorModel(cm_green)
gip:addColorModel(cm_red)

-------------
-- Sensors --
-------------

starting_light = cbc.AnalogSensor{4}

in_sensor = cbc.DigitalSensor{8} --if true, it is retracting
out_sensor = cbc.DigitalSensor{9} --if true, it is extending

lrange = cbc.AnalogSensor{2, float = true} --rangefinder on the left side of the robot
rrange = cbc.AnalogSensor{1, float = true} --rangefinder on the right side of the robot