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
local spTestBuildOrder = Spring.TestBuildOrder

--------------------------------------------------------------------------------
-- Original Code written by Arch-Shaman ----------------------------------------

local function CanUnitDropHere(unitDefID, x, y, z, facing, checkForFeature)
	local blocking, feature = spTestBuildOrder(unitDefID, x, y, z, facing)
	if checkForFeature then
		return blocking == 3 -- Recoil engine now has 3 for "free", 2 for "blocked by feature"
	else
		return blocking > 1
	end
end

local function GetClosestValidSpawnSpot(teamID, unitDefID, facing, x, z)
	local radius = 16
	local canDropHere = false
	local mag = 1
	local spiralChangeNumber = 1
	local movesLeft = 1
	local dir = 1 -- 1: right, 2: up, 3: left, 4 down
	local nx, ny, nz
	local offsetX, offsetZ = 0, 0
	local aborted = false
	repeat -- 1 right, 1 up, 2 left, 2 down, 3 right, 3 up
		nx = x + offsetX
		nz = z + offsetZ
		ny = Spring.GetGroundHeight(nx, nz)
		canDropHere = CanUnitDropHere(unitDefID, nx, ny, nz, facing, false)
		if canDropHere then
			return nx, ny, nz
		end
		if movesLeft == 0 and not (mag == 8 and movesLeft == 0 and dir == 4) then 
			spiralChangeNumber = spiralChangeNumber + 1
			if spiralChangeNumber%3 == 0 then 
				mag = mag + 1
			end
			movesLeft = mag
			dir = dir%4 + 1
		elseif mag == 8 and movesLeft == 0 and dir == 4 then -- abort
			aborted = true 
		else -- move to the next offset
			if dir == 1 then
				offsetX = offsetX + radius
			elseif dir == 2 then
				offsetZ = offsetZ + radius
			elseif dir == 3 then
				offsetX = offsetX - radius
			elseif dir == 4 then
				offsetZ = offsetZ - radius
			end
			movesLeft = movesLeft - 1
		end
	until canDropHere or aborted
	return x, Spring.GetGroundHeight(x, z), z -- aborted, return original position.
end

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
			index = unitIndex.count,
			defs = ichorDefs[unitDefID],
		}
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
	-- load active units
	for _, unitID in ipairs(Spring.GetAllUnits()) do
		local unitDefID = spGetUnitDefID(unitID)
		local teamID = spGetUnitTeam(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
end