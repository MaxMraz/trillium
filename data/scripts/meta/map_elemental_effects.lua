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
  for e in map:get_entities() do
    local DIST = 22
    if e:get_distance(x, y) <= DIST and (e.can_burn or e:get_property("can_burn") ) then
      local ex, ey, ez = e:get_position()
      sol.timer.start(map, map.fire_propagation_delay or 750, function()
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



----Ice-----------------------
function map_meta:create_ice_sparkle(x,y,z)
  local map = self
  local sparkle = map:create_custom_entity{
    x=x, y=y, layer=z, direction=0, width=32, height=32,
    model = "elements/ice_sparkle",
  }
  sparkle:set_origin(16, 16)
  return sparkle
end

function map_meta:create_ice_platform(x,y,z)
  local map = self
  local platform = map:create_custom_entity{
    x=x, y=y, layer=z, direction=0, width=32, height=32,
    model = "elements/ice_platform",
  }
  return platform
end

function map_meta:create_ice_block(x, y, z)
  local map = self
  local block = map:create_custom_entity{
    x=x, y=y, layer=z, direction=0, width=16, height=16,
    sprite = "elements/ice_block",
    model = "elements/ice_block",
  }
  return block
end
