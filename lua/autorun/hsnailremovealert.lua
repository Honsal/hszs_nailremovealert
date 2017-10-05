if SERVER then
	include("hsnailremovealert/init.lua")
	AddCSLuaFile("hsnailremovealert/cl_init.lua")
	AddCSLuaFile("hsnailremovealert/shared.lua")
end

if CLIENT then
	include("hsnailremovealert/cl_init.lua")
end