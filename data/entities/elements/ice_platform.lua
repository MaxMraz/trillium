local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local sprite

function entity:on_created()
  sprite = entity:create_sprite("elements/ice_platform")

  entity:set_size(40, 40)
  entity:set_origin(20,20)
  entity:set_can_traverse_ground("deep_water", true)
  entity:set_can_traverse_ground("shallow_water", false)
  entity:set_modified_ground("traversable")

  sprite:set_animation("growing", "stopped")
end

function entity:react_to_fire()
  entity:get_sprite():set_animation("melting", function() entity:remove() end)
end
