local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local sprite
local CONDUCTIVE_DISTANCE = 26

local power_entities = {
  "elements/lightning_zap",
  "elements/lightning_static",
}

function entity:on_created()
  entity.can_conduct_electricity = true
  sprite = entity:get_sprite()
  entity:set_size(16, 16)
  entity:set_drawn_in_y_order(true)
  entity:set_traversable_by(false)

  sol.timer.start(entity, 50, function()
    entity:check_for_power()
    return true
  end)
end

function entity:turn_on()
  sprite:set_animation"activated"
  if entity.on_activated then entity:on_activated() end
  entity.turned_on = true
end


function entity:turn_off()
  sprite:set_animation"inactivated"
  if entity.on_unactivated then entity:on_inactivated() end
  entity.turned_on = false
end

function entity:check_for_power()
    local x, y, z = entity:get_position()
    local CD = CONDUCTIVE_DISTANCE
    local powered = false
    for e in map:get_entities() do
      if e.electrified and e:get_distance(entity) <= CD then powered = true

      elseif e:get_type() == "custom_entity" and e:get_distance(entity) <= CD then
        for _, type in pairs(power_entities) do
          if e:get_model() == type then
            powered = true
          end
        end

      end
    end

    if powered and not entity.turned_on then entity:turn_on()
    elseif not powered and entity.turned_on then entity:turn_off() end

    return powered
end
