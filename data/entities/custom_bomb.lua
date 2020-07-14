local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local sprite

function entity:on_created()
  sprite = entity:create_sprite"entities/bomb"
  entity:set_traversable_by(false)
  entity:set_traversable_by("hero", true)
  entity:set_drawn_in_y_order(true)
  entity:set_follow_streams(true)
  entity:set_traversable_by("enemy", false)
  entity:set_weight(0)
  entity:set_size(16, 16)

  sol.timer.start(entity, 200, function() entity:spark_up() end)

end




function entity:on_lifting(carrier, carried_object)
  carried_object:set_damage_on_enemies(2)
  carried_object:set_destruction_sound("bomb")


  function carried_object:on_breaking()
    local x, y, layer = carried_object:get_position()
    local new_bomb = carried_object:get_map():create_custom_entity({
      width = 16, height = 16, x = x, y = y, layer = layer,
      direction = 0, model = "custom_bomb"
    })
    carried_object:remove()
  end

end

function entity:spark_up()
  local bomb = entity
  sol.timer.start(bomb, 200, function()
    sol.audio.play_sound"fuse"
    bomb:get_sprite():set_animation("stopped_explosion_soon")
  end)
  sol.timer.start(bomb, 2000, function()
    bomb:explode()
  end)
end

function entity:explode()
  local bomb = entity
  local map = bomb:get_map()
  local x, y, layer = bomb:get_position()
  map:create_explosion{x=x,y=y,layer=layer}
  sol.audio.play_sound"explosion"  
  sol.timer.stop_all(bomb)
  bomb:remove()
end

function entity:react_to_fire()
  sol.timer.start(entity, 100, function() entity:explode() end)
--  entity:explode()
end