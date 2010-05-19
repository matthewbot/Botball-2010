local cbc 			= require "cbclua.cbc"
local vision 		= require "cbclua.vision"
local servoutils 	= require "mb.servoutils"
local motorutils 	= require "mb.motorutils"

------------
-- Motors --
------------

ldrive 	= motorutils.JerkFixMotor{0}
rdrive 	= motorutils.JerkFixMotor{3}

lpitch 	= motorutils.JerkFixMotor{1}
rpitch 	= motorutils.JerkFixMotor{2}

------------
-- Servos --
------------

extend_servo 	= servoutils.SpeedControlServo{1}

fligger_servo 	= servoutils.SpeedControlServo{2}

------------
-- Vision --
------------

green_channel = vision.Channel(0)

-------------
-- Sensors --
-------------

pitch_down_switch 	= cbc.DigitalSensor{14}
Pitch_up_switch 	= cbc.DigitalSensor{2}