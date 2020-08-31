--Requires multi_events
--Note: only supports a square grid of items, vert and horizontal spacing are equal










--TODO
-- Draw the menu onto an intermediary surface, and scroll it beyond the limits of that surface
--See 





local builder = {}

local cursor_sprite = sol.sprite.create("menus/inventory/selector")
local item_square = sol.surface.create(24, 24)
item_square:fill_color{20,20,20}
item_square:set_opacity(150)


function builder:build(props)

  local menu = {}

  local screen_width, screen_height = sol.video.get_quest_size()
	local all_items = props.all_items
	local num_rows = props.num_rows or 4
	local num_columns = props.num_columns or 5
	local spacing = props.spacing or 32 --one item every X pixels
	local menu_width = props.menu_width or (num_columns * spacing)
	local menu_height = props.menu_height or (num_rows * spacing)
	local menu_x = props.menu_x or (screen_width - menu_width) / 2 
	local menu_y = props.menu_y or 40
  local hide_0_amount_items = props.hide_0_amount_items or false
  local menu_background_color = {100,100,100}

	local cursor_index = 0
  menu.scroll_steps = 0

  --Enable multi_events for the menu so on_started can be defined differently for each instance
  require("scripts/multi_events"):enable(menu)


  menu:register_event("on_started", function()
    local game = sol.main.get_game()

  	--Clear held items table to prevent duplicates
  	menu.held_items = {}
  	menu.item_sprites = {}

    --Make table of held items
	  for i = 1, #all_items do
	  	local item_name = all_items[i]
	  	if game:get_item(item_name):get_variant() > 0 then
        if (hide_0_amount_items
          and game:get_item(item_name):get_amount_savegame_variable()
          and game:get_item(item_name):has_amount(1))
        or (not hide_0_amount_items) then
  		  	local item = {}
          item.item = game:get_item(item_name)
  		  	item.index = i - 1
  		  	item.index_x = item.index % num_columns
  		  	item.index_y = math.floor(item.index / num_columns)
  		  	-- print("item index, x, y: ", item.index, item.index_x, item.index_y)
  		  	item.sprite = sol.sprite.create("entities/items")
  		  	item.sprite:set_animation(item_name)
  		  	item.sprite:set_direction(game:get_item(item_name):get_variant() - 1)
  	  		table.insert(menu.held_items, item)
        end
	  	end
	  end

    --Make a surface for all held items, we'll scroll this surface
    local menu_draw_height = math.max(spacing, math.ceil(#menu.held_items / num_columns) * spacing)
  	menu.items_surface = sol.surface.create(menu_width, menu_draw_height)

    --Draw items onto items_surface
  	menu.items_surface:clear()
  	for i, item in pairs(menu.held_items) do
  		item_square:draw(menu.items_surface, item.index_x * spacing + 4, item.index_y * spacing)
  		item.sprite:draw(menu.items_surface, item.index_x * spacing + (spacing/2), item.index_y * spacing + spacing/2)
  	end

    --Then make a surface to draw the items surface on
    menu.menu_surface = sol.surface.create(menu_width, menu_height)
    menu.menu_surface:fill_color(menu_background_color)

    --Note current highest and lowest indexes, to scroll if exceeded
    menu.current_lowest_index = 0
    menu.current_highest_index = num_rows * num_columns - 1

  end)


  menu:register_event("on_draw", function(self, dst)
    menu.menu_surface:clear()

  	cursor_sprite:draw(
  		menu.menu_surface,
  		cursor_index % num_columns * spacing,
  		math.floor(cursor_index / num_columns) * spacing - 4
		)

  	menu.items_surface:draw(menu.menu_surface, 0, (menu.scroll_steps or 0) * spacing)

    menu.menu_surface:draw(dst, menu_x, menu_y)
  end)


  function menu:scroll_down()
    menu.scroll_steps = (menu.scroll_steps or 0) + 1
    menu.current_highest_index = menu.current_highest_index + num_columns
    menu.current_lowest_index = menu.current_lowest_index + num_columns
  end

  function menu:scroll_up()
    menu.scroll_steps = (menu.scroll_steps or 0) + 1
    if menu.scroll_steps < 0 then menu.scroll_steps = 0 end
    menu.current_highest_index = menu.current_highest_index - num_columns
    menu.current_lowest_index = menu.current_lowest_index - num_columns    
  end


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

    if cursor_index > menu.current_highest_index then menu:scroll_down() end
    if cursor_index < menu.current_lowest_index then menu:scroll_up() end

  	return handled
  end


  return menu
end

return builder