local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local sprite

function entity:on_created()
  sprite = entity:create_sprite("elements/ice_sparkle")
  sprite:set_animation("sparkle", function() entity:remove() end)

  entity:add_collision_test("sprite", function(entity, other_entity)
    if other_entity.react_to_ice then
      other_entity:react_to_ice()
    end
  end)

  if entity:get_ground_below() == "shallow_water" or entity:get_ground_below() == "deep_water" then
    map:create_ice_platform(entity:get_position())

  elseif entity:get_ground_below() == "traversable" or entity:get_ground_below() == "grass" then
    map:create_ice_block(entity:get_position())
  end

end
