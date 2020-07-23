local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
item:register_event("on_started", function(self)
  item:set_savegame_variable("possession_hookseed_satchel")
  item:set_assignable(true)
end)

-- Event called when the hero is using this item.
item:register_event("on_using", function(self)
  local map = item:get_map()
  local hero = game:get_hero()
  local direction = hero:get_direction()
  local can_seed = true

  if hero:test_obstacles(game:dx(16)[direction], game:dy(16)[direction]) then
    can_seed = false
  end
  local x, y, z = hero:get_position()
  x = x + game:dx(16)[direction]
  y = y + game:dy(16)[direction]
  if map:get_ground(x, y, z) ~= "traversable" and map:get_ground(x,y,z) ~= "grass" then
    can_seed = false
  end

  if not can_seed then
    sol.audio.play_sound"wrong"
    item:set_finished()
    return
  end

  local width, height = 8, 8
  local sapling = map:create_custom_entity{x=x, y=y, layer=z, width=width, height=height, direction=0,
    model = "hookseed",
  }
  sapling:set_origin(width/2, height - 3)

  item:set_finished()
end)

