local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local sprite

function entity:on_created()
  entity:set_size(16,16)
  entity:set_drawn_in_y_order(true)
  entity:set_follow_streams(false)
  entity:set_can_traverse_ground("hole", true)
  entity:set_can_traverse_ground("shallow_water", true)
  entity:set_can_traverse_ground("deep_water", true)
  entity:set_can_traverse_ground("lava", true)
  entity:set_can_traverse_ground("low_wall", true)

  sprite = entity:create_sprite("elements/lightning_ball_small")


  sol.timer.start(entity, 50, function()
    if not entity:get_movement() then entity:remove() end
    local m = entity:get_movement()
    function m:on_obstacle_reached()
      local x,y,z = entity:get_position()
      map:create_lightning{x=x, y=y, layer=z, type="lightning_zap"}
      entity:remove()
    end
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

