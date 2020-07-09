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

function map_meta:propagate_fire(x, y, z)
  local num_flames = 8
  for i=1, num_flames do
    local flame = self:create_fire{x=x, y=y, layer=z}
    local m = sol.movement.create"straight"
    m:set_max_distance(10)
    m:set_angle(2* math.pi / num_flames * i)
    m:start(flame)
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