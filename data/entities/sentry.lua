local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero = map:get_hero()
local alert_threshold = 10
local too_close_distance = 24 --distance to sentry at which angle doesn't matter, you're too close

function entity:on_created()
  entity:set_drawn_in_y_order(true)

  entity.vision_angle = entity:get_property("vision_angle") or 70
  entity.vision_distance = entity:get_property("vision_distance") or 150

  entity.alert_level = 0
  entity.starting_position_x, entity.starting_position_y = entity:get_position()

  entity:start_watch()
  
end

--Normalize angle
function normalize(angle)
  return ((angle + math.pi) % (2 * math.pi)) - math.pi
end


function entity:start_watch()
  sol.timer.start(entity, 50, function()
    --Check hero angle and distance:
    local sentry_angle = entity:get_sprite():get_direction() * math.pi / 2

    -- if delta between enemy facing angle and angle to hero is greater than vision threshold, or if hero is too far away
    if ( math.abs(normalize(sentry_angle) - normalize(entity:get_angle(hero)) ) > math.rad(entity.vision_angle) and entity:get_distance(hero) > too_close_distance )
    or not map:is_on_screen(entity) then
      return true
    end

    --Create entity to check for line of sight
    local x, y, z = entity:get_position()
    local ray = map:create_custom_entity{
      x = x, y = y, layer = z, direction = 0,
      width = 8, height = 8, sprite = "entities/shadow"
    }
    ray:set_can_traverse("hero", true)
    ray:set_can_traverse("custom_entity", true)
    ray:set_can_traverse("jumper", true)
    ray:set_can_traverse("stairs", true)
    ray:set_can_traverse("stream", true)
    ray:set_can_traverse("switch", true)
    ray:set_can_traverse("teletransporter", true)
    ray:set_can_traverse_ground("deep_water", true)
    ray:set_can_traverse_ground("shallow_water", true)
    ray:set_can_traverse_ground("hole", true)
    ray:set_can_traverse_ground("lava", true)
    ray:set_can_traverse_ground("prickles", true)
    --Send ray toward hero
    local m = sol.movement.create"straight"
    m:set_smooth(false)
    m:set_speed(800)
    m:set_angle(entity:get_angle(hero))
    m:set_max_distance(entity.vision_distance)
    m:start(ray, function() ray:remove() end)
    function m:on_obstacle_reached() ray:remove() end

    --If hero is seen
    ray:add_collision_test("overlapping", function(ray, other_entity)
      if other_entity:get_type() == "hero" then
        ray:remove()        
        entity.alert_level = math.min(entity.alert_level + 1, alert_threshold)
        entity:process_alert_level()
      --Allow to hide in foliage 32px tall or higher
      elseif other_entity:get_type() == "custom_entity" and other_entity:get_model() == "foliage" then
        local _, height = other_entity:get_sprite():get_size()
        if height >= 32 then ray:remove() end
      end
    end)

    return true
  end)

  --Bring alert level down gradually
  sol.timer.start(entity, 300, function()
    entity.alert_level = math.max(entity.alert_level - 1, 0)
    entity:process_alert_level()
    return true
  end)
end


function entity:process_alert_level()
  --Suspicious, hasn't been:
  if entity.alert_level > 0 and not entity.alert_sprite then
    entity.alert_sprite = entity:create_sprite("entities/suspicion_indicator")
    sol.audio.play_sound"picked_money"

  elseif entity.alert_level == 0 and entity.alert_sprite then
    entity:remove_sprite(entity.alert_sprite)
    entity.alert_sprite = nil

  elseif entity.alert_level > 0 and entity.alert_level < alert_threshold then
    --If suspicious, look toward hero
    entity:get_sprite():set_direction(entity:get_direction4_to(hero))
    entity.alert_sprite:set_animation"suspicious"

  elseif entity.alert_level >= alert_threshold then
    entity.alert_sprite:set_animation("alert")
    if not entity.alerted then entity:alert() end
    entity.alerted = true

  end
end


function entity:alert()
  sol.audio.play_sound("picked_small_key")
  sol.timer.stop_all(entity)
  print"AAAAAAAAAAAAALLLLLLLLEEEERRRRT ALERTED!!!!"
  entity:set_layer(map:get_max_layer())
  local m = sol.movement.create"straight"
  m:set_angle(hero:get_angle(entity))
  m:set_speed(180)
  m:set_ignore_obstacles(true)
  m:start(entity)
  sol.timer.start(entity, 300, function()
    if map:is_on_screen(entity) then
      return true
    else
      entity:remove()
    end
  end)
end