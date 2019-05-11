
------------
-- Purpose: Hooks CopDamage:die() for unit deregistration and contour removal upon unit death (server-side)
------------

-- This is called on the server whenever a unit dies, regardless of the attacker being the local player or AI
local die_actual = CopDamage.die
function CopDamage:die(attack_data)
	die_actual(self, attack_data)

	-- Here's hoping the table never ends up in a corrupt state...
	if IntimidatedOutlines.TrackedUnits[self._unit] then
		IntimidatedOutlines.TrackedUnits[self._unit] = nil

		local contour = self._unit:contour()
		if not contour then
			return
		end

		contour:remove(IntimidatedOutlines.ContourTypeToApply, true)
	end
end
