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

local spCreateUnit = Spring.CreateUnit

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local UPDATE_FREQUNECY, ichorDefs = include("LuaRules/Configs/ichor_spread_defs.lua")
local CEG_SPAWN = [[dirt2]]

local units = {}
local unitIndex = {count = 0, info = {}}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GameFrame(f)
	
end
