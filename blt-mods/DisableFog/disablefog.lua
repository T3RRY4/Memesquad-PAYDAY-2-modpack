core:module("CoreEnvironmentFeeder")
core:import("CoreClass")
core:import("CoreCode")
core:import("CoreEngineAccess")
local ids_fog_max_range = Idstring("fog_max_range")
local ids_fog_min_range = Idstring("fog_min_range")
local ids_deferred = Idstring("deferred")
local ids_deferred_lighting = Idstring("deferred_lighting")
local ids_apply_ambient = Idstring("apply_ambient")
local ids_apply_ambient_id = Idstring("post_effect/deferred/deferred_lighting/apply_ambient"):key()
local zero_rotation = Rotation(0, 0, 0)
local zero_vector3 = Vector3(0, 0, 0)
local temp_rotation = Rotation(0, 0, 0)
local temp_vector3 = Vector3(0, 0, 0)
Feeder = Feeder or CoreClass.class()
Feeder.APPLY_GROUP_ID = 0
Feeder.DATA_PATH_KEY = nil
Feeder.IS_GLOBAL = nil
Feeder.AFFECTED_LIST = nil
Feeder.FILTER_CATEGORY = "Others"
function Feeder:init(current)
	self:set(current)
end
function Feeder:destroy()
	self._source = nil
	self._target = nil
end
function Feeder.get_next_id()
	Feeder.APPLY_GROUP_ID = Feeder.APPLY_GROUP_ID + 1
	return Feeder.APPLY_GROUP_ID
end
function Feeder:set_target(target)
	self._source = self._current
	self._target = target
end
function Feeder:equals(value)
	return self._current == value
end
function Feeder:get_current()
	return self._current
end
function Feeder:get_default_value()
	return Feeder.DEFAULT_VALUE
end
function Feeder:set(current)
	self._current = current
	self._source = current
	self._target = current
end
function Feeder:get_modifier()
	return self._modifier_func, self._is_modifier_override
end
function Feeder:set_modifier(modifier_func, is_modifier_override)
	self._modifier_func = modifier_func
	self._is_modifier_override = is_modifier_override
end
GlobalLightColorFeeder = GlobalLightColorFeeder or CoreClass.class(Vector3Feeder)
GlobalLightColorFeeder.DATA_PATH_KEY = Idstring("others/sun_ray_color"):key()
GlobalLightColorFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
GlobalLightColorFeeder.IS_GLOBAL = true
GlobalLightColorFeeder.FILTER_CATEGORY = "Sun"
function GlobalLightColorFeeder:apply(handler, viewport, scene)
	if alive(Global._global_light) then
		local color = handler:get_value(GlobalLightColorFeeder.DATA_PATH_KEY)
		if color then
			local color_scale = handler:get_value(GlobalLightColorScaleFeeder.DATA_PATH_KEY) or 1
			mvector3.set(temp_vector3, color)
			mvector3.multiply(temp_vector3, color_scale)
			Global._global_light:set_color(temp_vector3)
		else
			Global._global_light:set_color(zero_vector3)
		end
	else
		Application:error("[EnvironmentManager][GlobalLightFeeder] No underlay loaded.")
	end
end
GlobalLightColorScaleFeeder = GlobalLightColorScaleFeeder or CoreClass.class(Feeder)
GlobalLightColorScaleFeeder.DATA_PATH_KEY = Idstring("others/sun_ray_color_scale"):key()
GlobalLightColorScaleFeeder.APPLY_GROUP_ID = GlobalLightColorFeeder.APPLY_GROUP_ID
GlobalLightColorScaleFeeder.IS_GLOBAL = GlobalLightColorFeeder.IS_GLOBAL
GlobalLightColorScaleFeeder.FILTER_CATEGORY = GlobalLightColorFeeder.FILTER_CATEGORY
GlobalLightColorScaleFeeder.apply = GlobalLightColorFeeder.apply
CubeMapTextureFeeder = CubeMapTextureFeeder or CoreClass.class(StringFeeder)
CubeMapTextureFeeder.DATA_PATH_KEY = Idstring("others/global_texture"):key()
CubeMapTextureFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
CubeMapTextureFeeder.IS_GLOBAL = true
CubeMapTextureFeeder.FILTER_CATEGORY = "Cubemap"
function CubeMapTextureFeeder:apply(handler, viewport, scene)
	managers.global_texture:set_texture("current_global_texture", self._current, "CUBEMAP")
end
PostFogMinRangeFeeder = PostFogMinRangeFeeder or CoreClass.class(Feeder)
PostFogMinRangeFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/fog_min_range"):key()
PostFogMinRangeFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostFogMinRangeFeeder.IS_GLOBAL = nil
PostFogMinRangeFeeder.FILTER_CATEGORY = "Fog"
function PostFogMinRangeFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)
	material:set_variable(ids_fog_min_range, "10000000")
end
PostFogMaxRangeFeeder = PostFogMaxRangeFeeder or CoreClass.class(Feeder)
PostFogMaxRangeFeeder.DATA_PATH_KEY = Idstring("post_effect/deferred/deferred_lighting/apply_ambient/fog_max_range"):key()
PostFogMaxRangeFeeder.APPLY_GROUP_ID = Feeder.get_next_id()
PostFogMaxRangeFeeder.IS_GLOBAL = nil
PostFogMaxRangeFeeder.FILTER_CATEGORY = "Fog"
function PostFogMaxRangeFeeder:apply(handler, viewport, scene)
	local material = handler:_get_post_processor_modifier_material(viewport, scene, ids_apply_ambient_id, ids_deferred, ids_deferred_lighting, ids_apply_ambient)
	material:set_variable(ids_fog_max_range, "10000000")
end