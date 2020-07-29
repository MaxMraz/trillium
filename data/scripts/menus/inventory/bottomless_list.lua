--Requires multi_events

local builder = {}

local cursor_sprite = sol.sprite.create("menus/inventory/selector")
local item_square = sol.surface.create(24, 24)
item_square:fill_color{20,20,20}
item_square:set_opacity(150)


function builder:build(props)
	local all_items = props.all_items
	local num_rows = props.num_rows or 4
	local num_columns = props.num_columns or 5
	local spacing = props.spacing or 32
	local menu_width = props.menu_width or (num_columns * spacing)
	local menu_height = props.menu_height or 200
	local menu_x = props.menu_x or (416 - menu_width) / 2 --hardcoded 416 as the game width
	local menu_y = props.menu_y or 40

	local cursor_index = 0

	local game = sol.main.get_game()
  local menu = {}

  --Enable multi_events for the menu so on_started can be defined differently for each instance
  require("scripts/multi_events"):enable(menu)

  menu:register_event("on_started", function()
  	--Clear held items table to prevent duplicates
  	menu.held_items = {}
  	menu.item_sprites = {}
  	menu.items_surface = sol.surface.create(menu_width, menu_height)
  	-- menu.items_surface:fill_color{40,40,40}
  	-- menu.items_surface:set_opacity(150)

	  for i = 1, #all_items do
	  	local item_name = all_items[i]
	  	if game:get_item(item_name):get_variant() > 0 then
		  	local item = {}
		  	item.index = i - 1
		  	item.index_x = item.index % num_columns
		  	item.index_y = math.floor(item.index / num_columns)
		  	print("item index, x, y: ", item.index, item.index_x, item.index_y)
		  	item.sprite = sol.sprite.create("entities/items")
		  	item.sprite:set_animation(item_name)
		  	item.sprite:set_direction(game:get_item(item_name):get_variant() - 1)
	  		table.insert(menu.held_items, item)
	  	end
	  end
  end)


  menu:register_event("on_draw", function(self, dst)
  	menu.items_surface:clear()
  	for i, item in ipairs(menu.held_items) do
  		item_square:draw(menu.items_surface, item.index_x * spacing + 4, item.index_y * spacing)
  		item.sprite:draw(menu.items_surface, item.index_x * spacing + (spacing/2), item.index_y * spacing + spacing/2)
  	end
  	cursor_sprite:draw(
  		menu.items_surface,
  		cursor_index % num_columns * spacing,
  		math.floor(cursor_index / num_columns) * spacing - 4
		)
  	menu.items_surface:draw(dst, menu_x, menu_y)
  end)


  function menu:on_command_pressed(cmd)
  	local handled = false

  	if cmd == "right" then
  		cursor_index = cursor_index + 1
  		handled = true

  	elseif cmd == "left" then
  		cursor_index = cursor_index - 1
  		handled = true

  	elseif cmd == "down" then
  		cursor_index = cursor_index + num_columns
  		handled = true

  	elseif cmd == "up" then
  		cursor_index = cursor_index - num_columns
  		handled = true

  	end

  	if cursor_index < 0 then cursor_index = 0 end
  	if cursor_index > #menu.held_items - 1 then cursor_index = #menu.held_items - 1 end

  	return handled
  end


  return menu
end

return builder