local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

require("lib/units/weapons/RaycastWeaponBase")
require("lib/units/weapons/NewRaycastWeaponBase")
require("lib/units/weapons/shotgun/ShotgunBase")
ShotgunBase.mws_update_stats_values = ShotgunBase._update_stats_values
