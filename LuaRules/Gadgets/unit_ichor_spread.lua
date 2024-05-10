function gadget:GetInfo()
	return {
		name      = "Ichor Spread",
		desc      = "",
		author    = "IcarusRTS",
		date      = "",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--SYNCED
if (not gadgetHandler:IsSyncedCode()) then
	return false
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local random = math.random

local spGetUnitPosition = Spring.GetUnitPosition
local spGetUnitTeam = Spring.GetUnitTeam
local spCreateUnit = Spring.CreateUnit
local spSpawnCEG = Spring.SpawnCEG

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local UPDATE_FREQUNECY, ichorDefs = include("LuaRules/Configs/ichor_spread_defs.lua")
local CEG_SPAWN = [[dirt2]]

local units = {}
local unitIndex = {count = 0, info = {}}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GameFrame(f)
	if f%UPDATE_FREQUNECY == 0 then
		for i = 1, unitIndex.count do
			local unit = units[unitIndex[i]]
			local x,y,z = spGetUnitPosition(unitIndex[i])
			local newId = spCreateUnit(unit.defs.spawns,x+random(-50,50),y,z+random(-50,50),random(0,3),spGetUnitTeam(unitIndex[i]))
			spSpawnCEG(CEG_SPAWN,
						fx, fy, fz,
						0, 0, 0,
						30, 30
					)
		end
	end
end
