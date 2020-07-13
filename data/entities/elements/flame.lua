local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local sprite
local BURN_DURATION = 1000

function entity:on_created()
  entity:set_size(16,16)
  entity:set_drawn_in_y_order(true)
  entity:set_follow_streams(true)

  --Animate, then burn out
  sprite = entity:create_sprite("elements/fire")
  sprite:set_animation("fire")
  sol.timer.start(entity, 1000, function()
    sprite:set_animation("fire_" .. math.random(1,2), function()
      entity:remove()
    end)
  end)

  --Interact with other entities
  map.burned_entities = {}

  entity:add_collision_test("sprite", function(entity, other_entity, fire_sprite, other_entity_sprite)
    if map.burned_entities[other_entity] then return end

    if other_entity.react_to_fire and not map.burned_entities[other_entity] then
      other_entity:react_to_fire(entity)

    elseif other_entity.can_burn or other_entity:get_property("can_burn")
    and not map.burned_entities[other_entity] then
      sol.timer.start(entity, 500, function()
        local x, y, z = other_entity:get_position()
        other_entity:remove()
        map:propagate_fire(x, y, z)
      end)
    end

    --only check this once per entity
    map.burned_entities[other_entity] = true
    sol.timer.start(map, 600, function() map.burned_entities.other_entity = false end)
  end)


  --Special collision with hero for damage
  entity:add_collision_test("overlapping", function(entity, other_entity)
    if other_entity:get_type() == "hero" and not entity.hurting_hero then
      other_entity:start_hurt(entity, (game:get_value"fire_damage" or 1))
      entity.hurting_hero = true
      sol.timer.start(entity, 500, function() entity.hurting_hero = false end)
    end
  end)

end

