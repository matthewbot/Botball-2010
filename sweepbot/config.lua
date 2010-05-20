local cbc 			= require "cbclua.cbc"
local vision 		= require "cbclua.vision"
local servoutils 	= require "mb.servoutils"
local motorutils 	= require "mb.motorutils"

------------
-- Motors --
------------

ldrive 	= motorutils.JerkFixMotor{0}
rdrive 	= motorutils.JerkFixMotor{3}

------------
-- Servos --
------------

extend_servo 	= servoutils.SpeedControlServo{2}
pitch_servo 	= servoutils.SpeedControlServo{1}

------------
-- Vision --
------------

green_channel = vision.Channel(0)

-------------
-- Sensors --
-------------

lrange = cbc.AnalogSensor{0, float = true}
rrange = cbc.AnalogSensor{1, float = true}