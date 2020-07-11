local map_meta = sol.main.get_metatable"map"

local function do_bush_things(bush)
  bush.can_burn = true

  local sprite = bush:get_sprite()

  bush:set_drawn_in_y_order(true)

  local width, height = sprite:get_size()
  width = bush:get_property("width") or width
  height = bush:get_property("height") or height
  bush:set_size(width, height)
  bush:set_origin(width/2, height - 3)
end

map_meta:register_event("on_started", function(self)
  local map = self
  for bush in map:get_entities_by_type"destructible" do
    if bush:get_sprite():get_animation_set():match("bush") then
      do_bush_things(bush)
    end
  end
end)