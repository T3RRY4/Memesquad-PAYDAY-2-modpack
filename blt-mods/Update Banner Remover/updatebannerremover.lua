MenuComponentManager.create_new_heists_gui = function(self, node) return end
--MenuComponentManager.Holo:Post(BLTNotificationsGui) = function(self) return end

BLTNotificationsGui = BLTNotificationsGui or blt_class( MenuGuiComponentGeneric )

local padding = 0 --10

-- Copied from NewHeistsGui
local SPOT_W = 32
local SPOT_H = 8
local BAR_W = 32
local BAR_H = 6
local BAR_X = (SPOT_W - BAR_W) / 2
local BAR_Y = 0
local TIME_PER_PAGE = 3 --6
local CHANGE_TIME = 1.5 --0.5

