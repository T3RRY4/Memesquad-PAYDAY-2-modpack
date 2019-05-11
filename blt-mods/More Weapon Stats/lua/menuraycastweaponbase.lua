local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

require("lib/units/weapons/RaycastWeaponBase")
require("lib/units/weapons/NewRaycastWeaponBase")
NewRaycastWeaponBase.mws_update_stats_values = NewRaycastWeaponBase._update_stats_values
