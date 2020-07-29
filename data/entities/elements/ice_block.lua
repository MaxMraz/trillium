local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local sprite

function entity:on_created()
  sprite = entity:get_sprite()
  entity:set_drawn_in_y_order(true)
  entity:set_traversable_by(false)
  entity:set_follow_streams(true)
  entity:set_size(16, 16)

  entity:set_traversable_by(false)
  entity:set_traversable_by("hero", entity.overlaps)
  entity:set_traversable_by("enemy", entity.overlaps)

end


function entity:react_to_fire()
  local size = 100
  sol.timer.start(entity, 40, function()
    if size >= 5 then
      size = size - 10
      sprite:set_scale(1, size / 100)
      return true
    else
      entity:remove()
    end
  end)
end