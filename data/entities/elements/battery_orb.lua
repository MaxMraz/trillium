local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local sprite
local CONDUCTIVE_DISTANCE = 24

map.battery_orb_activated_entities = {}

function entity:on_created()
  sprite = entity:create_sprite"elements/battery_orb"
  entity:set_drawn_in_y_order(true)
  entity:set_traversable_by(false)
  entity:set_follow_streams(true)
  entity:set_size(16, 16)

  entity:set_can_traverse_ground("shallow_water", true)

  sol.timer.start(entity, 500, function()
    entity:check_for_conductive_entities()
    return true
  end)

end

function entity:on_interaction()
  local direction = map:get_hero():get_direction()
  local m = sol.movement.create"straight"
  m:set_angle(direction * math.pi / 2)
  m:set_max_distance(16)
  m:set_smooth(false)
  m:start(entity)
end

function entity:check_for_conductive_entities()
    local x, y, z = entity:get_position()
    local CD = CONDUCTIVE_DISTANCE
    for e in map:get_entities_in_rectangle(x - CD, y - CD, CD*2, CD*2) do
      if not e.electrified
      and (e.can_conduct_electricity or e:get_property("can_conduct_electricity") )
      and e:get_distance(entity) <= CD then
        local ex, ey, ez = e:get_position()
        local static = map:create_lightning_static{x=x, y=y, layer=z, source=entity}
        sol.timer.start(map, 500, function() static:remove() end)
      end
    end
end