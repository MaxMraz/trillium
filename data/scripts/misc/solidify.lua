local manager

function manager:solidify(entity)
  local map = entity:get_map()
  local x, y, z = entity:get_position()
  local w, h = entity:get_size()

  sol.timer.start(entity, 10, function()
    if not entity:overlaps(map:get_hero()) then
      entity:set_traversable_by("hero", false)
    else return true
    end
  end)

  sol.timer.start(entity, 40, function()
    local overlaps = false
    for e in map:get_entities_in_rectangle(x - w/2, y - h/2, w, h) do
      if e:get_type() == "enemy" and entity:overlaps(e) then overlaps = true end
    end
    if overlaps == false then
      entity:set_traversable_by("enemy", false)
    else
      return true
    end
  end)
end


return manager