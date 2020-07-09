--This will be obviated once the bug where block type entities aren't recognized by "sprite" collision tests

local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local sprite

function entity:on_created()
  sprite = entity:get_sprite()
  entity.can_conduct_electricity = true
  entity:set_drawn_in_y_order(true)
  entity:set_traversable_by(false)
  entity:set_follow_streams(true)
  entity:set_size(16, 16)

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

function entity:on_interaction()
  local direction = map:get_hero():get_direction()
  local m = sol.movement.create"straight"
  m:set_angle(direction * math.pi / 2)
  m:set_max_distance(16)
  m:set_smooth(false)
  m:start(entity)
end
