local entity = ...
local game = entity:get_game()
local map = entity:get_map()

local state = require("scripts/action/climb_manager"):get_state()

function entity:on_created()
  entity:set_visible(false)
  local hero = map:get_hero()
  if not map.climbing_walls then map.climbing_walls = {} end

  for e in map:get_entities() do
    if e:get_type() == "custom_entity" and e:get_model() == "climbing_wall" then
      map.climbing_walls[e] = true
    end
  end

  hero:register_event("on_position_changed", function()
    local overlaps = false
    for wall, _ in pairs(map.climbing_walls) do
      if hero:overlaps(wall) then overlaps = true end
    end
    if overlaps and not state:is_started() then
      hero:start_state(state)
    elseif not overlaps and state:is_started() then
      hero:unfreeze()
    end
  end)

  hero:register_event("on_movement_changed", function(hero, movement)
    if hero:get_state_object() and hero:get_state_object():get_description() == "climbing" then
      if movement:get_speed() > 0 then
        hero:set_animation"climbing"
      else
        hero:set_animation"climbing_stopped"
      end
    end
  end)
end

