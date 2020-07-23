local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local sprite
local sound_manager = require("entities/foliage_sound_manager")
 entity.can_burn = true

-- Event called when the custom entity is initialized.
function entity:on_created()
  sprite = entity:get_sprite()
  if sprite:get_num_frames() > 1 then
    sprite:set_frame(math.random(1, sprite:get_num_frames() - 1))
  end
  entity:set_drawn_in_y_order()
  entity:set_traversable_by(true)


    entity:add_collision_test("overlapping", function(entity, other_entity)
      if other_entity:get_type() == "hero" and not entity.shaking then
        entity.shaking = true
        sound_manager:play_sound("walk_on_grass")
        if sprite:has_animation"shaking" then
          sprite:set_animation("shaking", function()
            sprite:set_animation("shaking", "stopped")
          end)
        end
        sol.timer.start(entity, 200, function()
          if entity:get_distance(other_entity) < 24 then
            return true
          else
            entity.shaking = false
          end
        end)
      end
    end)

end

function entity:react_to_fire()
  local x, y, z = entity:get_position()
  entity:remove()
--  map:create_fire{x=x, y=y, layer=z}
  map:propagate_fire(x, y, z)
end
