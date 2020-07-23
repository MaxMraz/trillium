local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local sprite

function entity:on_created()
  sprite = entity:create_sprite("entities/arrow")
  entity:set_can_traverse("hero", true)
  entity:set_can_traverse("crystal", true)
  entity:set_can_traverse("crystal_block", true)
  entity:set_can_traverse("jumper", true)
  entity:set_can_traverse("stairs", false)
  entity:set_can_traverse("stream", true)
  entity:set_can_traverse("switch", true)
  entity:set_can_traverse("teletransporter", true)
  entity:set_can_traverse_ground("deep_water", true)
  entity:set_can_traverse_ground("shallow_water", true)
  entity:set_can_traverse_ground("hole", true)
  entity:set_can_traverse_ground("lava", true)
  entity:set_can_traverse_ground("prickles", true)
  entity:set_can_traverse_ground("low_wall", true)

  local direction = entity:get_direction()
  local horizontal = direction % 2 == 0
  if horizontal then
    entity:set_size(16, 8)
    entity:set_origin(8, 6)
  else
    entity:set_size(8, 16)
    entity:set_origin(4, 8)
  end

end

function entity:on_movement_changed(m)
  sprite:set_direction(m:get_direction4())
end


function entity:apply_type(type)
  entity.type = type
end


function entity:fire(dir4)
  local m = sol.movement.create"straight"
  m:set_speed(190)
  m:set_angle(dir4 * math.pi/2)
  m:set_smooth(false)
  m:start(entity)

  function m:on_obstacle_reached()
    sprite:set_animation("reached_obstacle")
    sol.audio.play_sound("arrow_hit")
    entity:stop_movement()
    if entity.type then entity:create_effect() end
    sol.timer.start(map, 2500, function()
      entity:remove()
    end)
  end

end



function entity:create_effect()
  if entity.type == "fire" then
    local x, y, z = entity:get_position()
    map:create_fire{x=x, y=y, layer=z}
    entity:get_sprite():set_color_modulation{50,50,50}

  elseif entity.type == "ice" then
    map:create_ice_sparkle(entity:get_position())

  elseif entity.type == "electric" then
    local x, y, z = entity:get_position()
    local dir = entity:get_direction()
    map:create_lightning{x=x+game:dx(8)[dir], y=y+game:dy(8)[dir], layer=z}

  elseif entity.type == "bomb" then
    local x, y, z = entity:get_position()
    map:create_explosion{x=x, y=y, layer=z}
    entity:remove()

  end
end