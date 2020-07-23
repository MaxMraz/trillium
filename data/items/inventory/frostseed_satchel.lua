local item = ...
local game = item:get_game()

local DISTANCE = 28

-- Event called when the game is initialized.
item:register_event("on_started", function(self)
  item:set_savegame_variable("possession_frostseed_satchel")
  item:set_assignable(true)
end)

-- Event called when the hero is using this item.
item:register_event("on_using", function(self)
  local map = item:get_map()
  local hero = game:get_hero()
  local x, y, z = hero:get_position()
  local direction = hero:get_direction()
--  x = x + game:dx(16)[direction]
--  y = y + game:dy(16)[direction]
  local projectile = map:create_custom_entity{x=x, y=y, layer=z, direction=0, width=16, height=16,
    sprite="elements/snowflake_frisbee",
  }
  projectile:set_can_traverse_ground("hole", true)
  projectile:set_can_traverse_ground("deep_water", true)
  projectile:set_can_traverse_ground("shallow_water", true)
  projectile:set_can_traverse_ground("lava", true)
  local m = sol.movement.create"straight"
  m:set_angle(direction * math.pi / 2)
  m:set_speed(150)
  m:set_max_distance(DISTANCE)
  m:start(projectile, function()
    map:create_ice_sparkle(projectile:get_position())
    projectile:remove()
  end)
  function m:on_obstacle_reached()
    map:create_ice_sparkle(projectile:get_position())
    projectile:remove()
  end

  item:set_finished()
end)

