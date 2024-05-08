local unitArray = {}
local UPDATE_FREQUENCY = 30

for i=1,#UnitDefs do
	local cp = UnitDefs[i].customParams
	if cp.ichor_spread then
		unitArray[i] = {
			cooldown = tonumber (cp.ichor_spread_cooldown)*UPDATE_FREQUENCY/30,
			range = tonumber (cp.ichor_spread_range),
			spawns = cp.ichor_spread_spawn,
		}
	end
end

return UPDATE_FREQUENCY, unitArray