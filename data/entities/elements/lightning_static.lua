local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local sprite
local conductive_distance = 24

function entity:on_created()
  entity:set_size(16,16)
  entity:set_drawn_in_y_order(false)

  entity.electrified_entities = {}

  sprite = entity:create_sprite("elements/lightning_static")
  sprite:set_frame( math.random(1, sprite:get_num_frames()) - 1 )

  --Interact with other entities
  if not map.lightning_affected_entities then
    map.lightning_affected_entities = {}
  end

  entity:add_collision_test("sprite", function(entity, other_entity)
    if map.lightning_affected_entities[other_entity] then return end
    if other_entity.react_to_lightning then
      other_entity:react_to_lightning(entity)
    end
    --only check this once per entity
    map.lightning_affected_entities[other_entity] = true
    sol.timer.start(map, 500, function() map.lightning_affected_entities.other_entity = false end)
  end)


  --Special collision with hero for damage
  entity:add_collision_test("overlapping", function(entity, other_entity)
    if other_entity:get_type() == "hero" and not entity.hurting_hero then
      other_entity:start_hurt(entity, (game:get_value"electric_damage" or 1))
      entity.hurting_hero = true
      sol.timer.start(entity, 500, function() entity.hurting_hero = false end)
    end
  end)

  --Jump to nearby conductive entities
  sol.timer.start(entity, 200, function()
    local x, y, z = entity:get_position()
    local CD = conductive_distance
    for e in map:get_entities_in_rectangle(x - CD, y - CD, CD*2, CD*2) do
      if not e.electrified
      and (e.can_conduct_electricity or e:get_property("can_conduct_electricity")) then
        local ex, ey, ez = e:get_position()
        e.electrified = true
        local new_static = map:create_lightning_static{x=ex, y=ey, layer=ez, source = entity.source_entity}
        table.insert(new_static.electrified_entities, e)
      end
    end
    return entity.source_entity --repeat timer
  end)

end


function entity:set_source(source_entity)
  if source_entity == "none" then source_entity = nil end
  entity.source_entity = source_entity

  --If no source
  if not source_entity then
    sol.timer.start(entity, 1000, function()
      for _, e in pairs(entity.electrified_entities) do
        e.electrified = false
      end
      entity:remove()
    end)

  else
    sol.timer.start(entity, 500, function()
      if entity:get_distance(source_entity) > conductive_distance then
        for _, e in pairs(entity.electrified_entities) do
          e.electrified = false
        end
        entity:remove()
      else
        return true
      end
    end)

  end

end


