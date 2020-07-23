local manager = {}

local bad_grounds = {
  "deep_water",
  "hole",
  "lava",
}

--Entity types upon which we ought not save ground as solid:
local unstable_entities = {
  "elements/ice_platform",
}


local hero_meta = sol.main.get_metatable"hero"

hero_meta:register_event("on_position_changed", function(self)
  local hero = self
  local map = hero:get_map()

  local save_ground = true
  --don't save on bad grounds:
  for _, ground in pairs(bad_grounds) do
    if hero:get_ground_below() == ground then save_ground = false end
  end
  --don't save on bad entities:
  for entity in map:get_entities_by_type("custom_entity") do
    for _, type in pairs(unstable_entities) do
      if entity:get_model() == type and entity:overlaps(hero) then
        save_ground = false
      end
    end
  end

  if save_ground then
    hero:save_solid_ground()
  end

end)

return manager