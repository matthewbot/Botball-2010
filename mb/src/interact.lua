autorequire("mb.")

function test(mod)
	local testmod = require("tests." .. mod)
	for k,v in pairs(testmod) do
		if type(k) == "string" and type(v) == "function" and k:sub(1,5) == "test_" then
			print("Running " .. k)
			v()
		end
	end
end
		   
			
