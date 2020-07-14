local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
item:register_event("on_started", function(self)
  item:set_savegame_variable("possession_spark_spell")
  item:set_assignable(true)
end)

-- Event called when the hero is using this item.
item:register_event("on_using", function(self)
  local map = item:get_map()
  local hero = game:get_hero()
  local x, y, z = hero:get_position()
  local direction = hero:get_direction()
  x = x + game:dx(16)[direction]
  y = y + game:dy(16)[direction]
  local ball = map:create_lightning{x=x, y=y, layer=z, type="lightning_ball_small"}
  local m = sol.movement.create"straight"
  m:set_angle(direction * math.pi/2)
  m:set_max_distance(64)
  m:set_speed(150)
  m:set_smooth(false)
  m:start(ball, function() if ball:exists() then ball:remove() end end)

  item:set_finished()
end)

