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
local spGetUnitDefID = Spring.GetUnitDefID
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

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	if ichorDefs[unitDefID] then
		unitIndex.count = unitIndex.count + 1
		unitIndex[unitIndex.count] = unitID
	
		units[unitID] = {
			progress = 0,
			oldProgress = 0,
			index = unitIndex.count,
			defs = ichorDefs[unitDefID],
		}
		Spring.InsertUnitCmdDesc(unitID, gooGatherBehaviour)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	if ichorDefs[unitDefID] then
		unitIndex[units[unitID].index] = unitIndex[unitIndex.count] -- move index from end to index to be deleted
		units[unitIndex[unitIndex.count]].index = units[unitID].index -- update index of unit at end
		unitIndex[unitIndex.count] = nil -- remove index at end
		unitIndex.count = unitIndex.count - 1 -- remove index at end too
		units[unitID] = nil -- remove unit to be deleted
	end
end

function gadget:Initialize()
	Spring.SetGameRulesParam("ichorState",1)
	
	-- load active units
	for _, unitID in ipairs(Spring.GetAllUnits()) do
		local unitDefID = spGetUnitDefID(unitID)
		local teamID = spGetUnitTeam(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
end