SetVideo = false


    	for _, vp in ipairs(managers.viewport:viewports()) do
  vp:vp():set_post_processor_effect("World", Idstring("color_grading_post"), Idstring("empty"))

end
	


if Utils:IsInHeist() then
  SetVideo = true 
else
  SetVideo = false
  end
