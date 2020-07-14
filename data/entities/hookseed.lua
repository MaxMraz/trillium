local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local sprite

-- Event called when the custom entity is initialized.
function entity:on_created()
  entity:set_drawn_in_y_order()
  entity:set_traversable_by(false)

  entity.can_burn = true

  sprite = entity:create_sprite("foliage/hookseed")
  sprite:set_animation("growing", "grown")

  entity:add_collision_test("sprite", function(entity, other_entity, sprite, other_sprite)
    if other_sprite == map:get_hero():get_sprite("sword") then
      entity:clear_collision_tests()
      entity:set_traversable_by(true)
      entity:remove_sprite()
      local burst = entity:create_sprite("foliage/leaf_burst")
      sol.timer.start(entity, burst:get_num_frames() * burst:get_frame_delay(), function()
        entity:remove()
      end)
    end
  end)
end
