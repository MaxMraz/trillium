local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local sprite

function entity:on_created()
  sprite = entity:get_sprite()
  entity.can_conduct_electricity = true
  entity:set_drawn_in_y_order(true)
  entity:set_traversable_by(false)
  entity:set_traversable_by("hero", entity.overlaps)
  entity:set_traversable_by("enemy", entity.overlaps)

  entity:set_follow_streams(true)
  entity:set_size(16, 16)
  entity:set_weight(0)

  sol.timer.start(entity, 100, function()
--print(entity.electrified)
    if entity.electrified and sprite:get_animation() ~= "electrified" then
      sprite:set_animation"electrified"
    elseif not entity.electrified and sprite:get_animation() == "electrified" then
      sprite:set_animation"stopped"
    end
    return true
  end)
end

function entity:on_position_changed(x,y,z)
  for e in map:get_entities_in_rectangle(x-8,y-8,8,8) do
    if e:get_type() == "custom_entity" and e:get_model() == "elements/lightning_static" then
      e:set_position(x,y,z)
    end
  end
end

--[[
function entity:on_interaction()
  local direction = map:get_hero():get_direction()
  local m = sol.movement.create"straight"
  m:set_angle(direction * math.pi / 2)
  m:set_max_distance(16)
  m:set_smooth(false)
  m:start(entity)
end
--]]

entity:register_event("on_lifting", function(entity, carrier, carried_object)
  carried_object:set_destruction_sound("running_obstacle")

  --landing, and therefore needing to create a new toss_ball
  function carried_object:on_breaking()
    local x, y, layer = carried_object:get_position()
    local width, height = carried_object:get_size()
    local sprite = carried_object:get_sprite()
    local direction = sprite:get_direction()

    if carried_object:get_ground_below() == "wall" then y = y + 16 end
    local new_object = carried_object:get_map():create_custom_entity({
      width = width, height = height, x = x, y = y, layer = layer,
      direction = direction, model = "conductive_block", sprite = sprite:get_animation_set()
    })

    --For compatibility with the metal_block_cane item
    if game:get_item"inventory/metal_block_cane" then
      game:get_item("inventory/metal_block_cane").created_block = new_object
    end

  end

end)
