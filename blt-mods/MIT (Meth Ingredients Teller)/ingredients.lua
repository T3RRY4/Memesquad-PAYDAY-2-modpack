local ingredient_dialog = {}
toggle_ingredients_chat = true
ingredient_said = false
ingredient_dialog["pln_rt1_12"] = "Ingredient added" --Comment out the parts of the script you don't want in chat by adding two dashes at the start of the line
ingredient_dialog["pln_rt1_20"] = "Add Mu" --Commenting these parts out will stop them from being shown in game
ingredient_dialog["pln_rt1_22"] = "Add Cs"
ingredient_dialog["pln_rt1_24"] = "Add Hcl"
ingredient_dialog["pln_rt1_28"] = "Batch complete"
ingredient_dialog["pln_rat_stage1_20"] = "Add Mu"
ingredient_dialog["pln_rat_stage1_22"] = "Add Cs"
ingredient_dialog["pln_rat_stage1_24"] = "Add Hcl"
ingredient_dialog["pln_rat_stage1_28"] = "Batch complete"



local _queue_dialog_orig = DialogManager.queue_dialog
function DialogManager:queue_dialog(id, ...)
    if ingredient_dialog[id] == last_ingredient then
	ingredient_said = true
    else
	ingredient_said = false
    end
    if ingredient_dialog[id] and toggle_ingredients_chat and not ingredient_said then
	managers.chat:send_message(ChatManager.GAME, managers.network.account:username() or "Offline", ingredient_dialog[id]) --Comment this out to stop messages being sent in chat
	last_ingredient = ingredient_dialog[id]
    elseif ingredient_dialog[id] and not toggle_ingredients_chat then
	managers.hud:show_hint({text = ingredient_dialog[id]})
	last_ingredient = ingredient_dialog[id]
    end
    if ingredient_dialog[id] == "Add Mu" or ingredient_dialog[id] == "Add Cs" or ingredient_dialog[id] == "Add Hcl" then
	ingredient_said = true
    end
    return _queue_dialog_orig(self, id, ...)
end


