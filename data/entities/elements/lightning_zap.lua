local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local sprite

function entity:on_created()
  entity:set_size(16,16)
  entity:set_drawn_in_y_order(true)

  --Animate, then burn out
  sprite = entity:create_sprite("elements/lightning_zap")
  sprite:set_animation("zap", function() entity:remove() end)
  sol.timer.start(entity, 1000, function()
    entity:remove()
  end)

  --Interact with other entities
  if not map.lightning_affected_entities then map.lightning_affected_entities = {} end

  entity:add_collision_test("sprite", function(entity, other_entity, entity_sprite, other_entity_sprite)
    -- print(other_entity, "electrified:", other_entity.electrified, "tabled:", map.lightning_affected_entities[other_entity])

    --React to Lightning
    if other_entity.react_to_lightning and not map.lightning_affected_entities[other_entity] then
      other_entity:react_to_lightning(entity)
    end

    --Conductive Entities
    if not map.lightning_affected_entities[other_entity]
    and (not other_entity.electrified)
    and (other_entity.can_conduct_electricity or other_entity:get_property("can_conduct_electricity") ) then
      sol.timer.start(entity, 20, function()
        local x, y, z = other_entity:get_position()
        map:create_lightning_static{x=x, y=y, layer=z, source = "none"}
      end)
    end

    --only check this once per entity per unit of time
    map.lightning_affected_entities[other_entity] = true
    sol.timer.start(map, 800, function() map.lightning_affected_entities[other_entity] = nil end)
  end)


  --Special collision with hero for damage
  entity:add_collision_test("overlapping", function(entity, other_entity)
    if other_entity:get_type() == "hero" and not entity.hurting_hero then
      other_entity:start_hurt(entity, (game:get_value"electric_damage" or 1))
      entity.hurting_hero = true
      sol.timer.start(entity, 500, function() entity.hurting_hero = false end)
    end
  end)

end
