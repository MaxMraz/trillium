local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

-- Event called when the enemy is initialized.
function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(1)
end

function enemy:on_restarted()

  movement = sol.movement.create("random")
  movement:set_speed(24)
  movement:start(enemy)
end

function enemy:on_movement_changed(m)
  sprite:set_direction(m:get_direction4())
end
