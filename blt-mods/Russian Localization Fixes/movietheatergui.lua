local init_orig = MovieListItem.init
function MovieListItem:init(parent, item, ...)
	item.title = item.title:lower():gsub('offshore payday', 'оффшорные деньги')
						:gsub('somewhere in mexico', 'где-то в Мексике')
						:gsub('rumors and stories', 'сплетни и слухи')
	init_orig(self, parent, item, ...)
end