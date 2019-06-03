local text_orig = ExtendedPanel.fine_text
function ExtendedPanel:fine_text(config, ...)
	if config and config.text then
		config.text = config.text:gsub('(%d) (Jan) ', '%1 Янв ')
							:gsub('(%d) Feb ', '%1 Фев ')
							:gsub('(%d) Mar ', '%1 Мар ')
							:gsub('(%d) Apr ', '%1 Апр ')
							:gsub('(%d) May ', '%1 Мая ')
							:gsub('(%d) Jun ', '%1 Июн ')
							:gsub('(%d) Jul ', '%1 Июл ')
							:gsub('(%d) Aug ', '%1 Авг ')
							:gsub('(%d) Sep ', '%1 Сен ')
							:gsub('(%d) Oct ', '%1 Окт ')
							:gsub('(%d) Nov ', '%1 Ноя ')
							:gsub('(%d) Dec ', '%1 Дек ')
	end
	return text_orig(self, config, ...)
end