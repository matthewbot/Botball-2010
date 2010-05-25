BangBang = create_class "BangBang"

function BangBang:set_vel(drivetrain, lspeed, rspeed)
	drivetrain:drive(lspeed, rspeed)
end

function BangBang:set_vel_dist(drivetrain, lspeed, ldist, rspeed, rdist)
	drivetrain:drive_dist(lspeed, ldist, rspeed, rdist)
end
