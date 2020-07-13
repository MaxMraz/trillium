local map_meta = sol.main.get_metatable"map"

------Fire------
function map_meta:create_fire(props)
  --props: name, x, y, layer, enabled_at_start, properties
  local map = self
  local fire = map:create_custom_entity{
    x = props.x, y = props.y, layer = props.layer, width = 16, height = 16, direction = 0,
    model = "elements/flame", 
  }
  return fire
end

function map_meta:old_propagate_fire(x, y, z)
  local num_flames = 6
  for i=1, num_flames do
    local flame = self:create_fire{x=x, y=y, layer=z}
    local m = sol.movement.create"straight"
    m:set_max_distance(16)
    m:set_ignore_obstacles()
    m:set_angle(2* math.pi / num_flames * i)
    m:start(flame)
  end
end

function map_meta:propagate_fire(x, y, z)
  local map = self
  local DIST = 22
--[[
  for e in map:get_entities_in_rectangle(x - DIST, y - DIST, DIST * 2, DIST * 2) do
    if e.can_burn or e:get_property("can_burn") then
      local ex, ey, ez = e:get_position()
      map:create_fire{x=ex, y=ey, layer=ez}
    end
  end
--]]
  for e in map:get_entities() do
    local DIST = 22
    if e:get_distance(x, y) <= DIST and (e.can_burn or e:get_property("can_burn") ) then
      local ex, ey, ez = e:get_position()
      sol.timer.start(map, 800, function()
        map:create_fire{x=ex, y=ey, layer=ez}
      end)
    end
  end
end


----Lightning----------
function map_meta:create_lightning(props)
  local type = props.type or "lightning_zap"
  local lightning = self:create_custom_entity{
    x = props.x, y = props.y, layer = props.layer,
    width = props.width or 16, height = props.height or 16, direction = 0,
    model = "elements/" .. type,
  }
  return lightning
end

function map_meta:create_lightning_static(props)
  local lightning = self:create_custom_entity{
    x = props.x, y = props.y, layer = props.layer, width = 16, height = 16, direction = 0,
    model = "elements/lightning_static",
  }
  lightning:set_source(props.source or "none")
  return lightning
end