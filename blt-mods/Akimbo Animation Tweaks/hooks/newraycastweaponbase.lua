Hooks:PostHook(NewRaycastWeaponBase, "clbk_assembly_complete", "akimboanim_hideobject", function(self)
	local hidden_data = tweak_data.weapon[self._name_id].hidden_parts

	if hidden_data then
		for part_type, part_data in pairs(hidden_data) do
			local part_list = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk(part_type, self._factory_id, self._blueprint)

			for _, part_name in ipairs(part_list) do
				local part = self._parts[part_name]
				local objects = type(part_data) == "table" and (part_data[part_name] or part_data[1] and part_data) or true

				if objects then
					if type(objects) == "table" then
						for _, object_name in ipairs(objects) do
							local object = part.unit:get_object(Idstring(object_name))

							if alive(object) then
								object:set_visibility(false)

								if self._hidden_objects then
									self._hidden_objects[part_name] = self._hidden_objects[part_name] or {}

									table.insert(self._hidden_objects[part_name], object_name)
								end
							end
						end
					else
						part.unit:set_visible(false)
						self:_set_part_temporary_visibility(part_name, false)

						if self._hidden_objects then
							self._hidden_objects[part_name] = true
						end
					end
				end
			end
		end
	end
	

end)