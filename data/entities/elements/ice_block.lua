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

  entity:set_traversable_by("hero", true)
  entity:solidify()

end


function entity:solidify()
  sol.timer.start(entity, 10, function()
    if not entity:overlaps(map:get_hero()) then
      entity:set_traversable_by("hero", false)
    else return true
    end
  end)

  sol.timer.start(entity, 40, function()
    local overlaps = false
    for e in map:get_entities_by_type("enemy") do
      if entity:overlaps(e) then overlaps = true end
    end
    if not overlaps then entity:set_traversable_by("enemy", false) end
  end)
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