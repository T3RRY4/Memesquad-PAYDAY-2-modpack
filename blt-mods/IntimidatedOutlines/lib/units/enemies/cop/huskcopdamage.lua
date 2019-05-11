
------------
-- Purpose: Hooks HuskCopDamage:die() for unit deregistration and contour removal upon unit death (client-side)
------------

-- This is called on the client whenever a unit dies, regardless of the attacker being the local player or AI
local die_actual = HuskCopDamage.die
function HuskCopDamage:die(variant)
	die_actual(self, variant)

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
