require("scripts/multi_events")

local item = ...
local game = item:get_game()

item:register_event("on_created", function(self)
  item.can_throw = true
  self:set_savegame_variable("found_boomerang")
  self:set_assignable(true)
end)

--make it so when you enter a new map, you didn't leave the boomerang behind
sol.main.get_metatable("map"):register_event("on_started", function()
  item.can_throw = true
end)

item:register_event("on_using", function(self)

  local hero = self:get_map():get_entity("hero")
  if self:get_variant() == 1 and item.can_throw then
    self:do_boomerang(75, 170, "boomerang1", "entities/boomerang1")
    item.can_throw = false
  elseif item.can_throw then
    -- boomerang 2: longer and faster movement
    self:do_boomerang(170, 250, "boomerang1", "entities/boomerang1")
    item.can_throw = false
  end
  self:set_finished()
end)

function item:do_boomerang(distance, speed, hero_animation, boom_sprite)
  local hero = game:get_hero()
  local map = item:get_map()
  hero:freeze()
  hero:get_sprite():set_animation(hero_animation, function() hero:unfreeze() end)
  local x,y,l = hero:get_position()

  --make boomerang
  local boomerang = map:create_custom_entity({
    direction = 0, x = x, y = y, layer = l, width = 16, height = 16,
    sprite = boom_sprite, name = "hero_thrown_boomerang"
  })
  boomerang:set_can_traverse_ground("deep_water", true)
  boomerang:set_can_traverse_ground("shallow_water", true)
  boomerang:set_can_traverse_ground("hole", true)
  boomerang:set_can_traverse_ground("lava", true)
  boomerang:set_can_traverse_ground("low_wall", true)
  boomerang:set_can_traverse("hero", true)

  --manage hitting stuff
  boomerang:add_collision_test("sprite", function(boom, enemy)
    if enemy:get_type() == "enemy" then
      item:smack_enemy(enemy)
    end
  end)

  --throw
  local m = sol.movement.create("straight")
  m:set_max_distance(distance)
  m:set_speed(speed)
  m:set_ignore_obstacles(false)
  local angle_options = {[0]=0,[1]=math.pi/2,[2]=math.pi,[3]=3*math.pi/2}
  m:set_angle(angle_options[hero:get_sprite():get_direction()])
  m:start(boomerang, function() item:come_back(boomerang, speed) end)
  function m:on_obstacle_reached()
    item:come_back(boomerang, speed)
  end
  sol.timer.start(map, 160, function()
    if map:has_entities("hero_thrown_boomerang") then
      sol.audio.play_sound("boomerang")
      return true
    end
  end)

  --Create feathers to hurt enemies if second level
  if self:get_variant() > 1 then
    sol.timer.start(map, 130, function()
      if map:has_entities("hero_thrown_boomerang") then
        local x,y,z = boomerang:get_position()
        local feather = map:create_custom_entity{
          x=x, y=y, layer=z, direction=0, width=16, height=16,
          model = "damaging_sparkle", sprite = "enemies/crow_feather"
        }
        feather:set_damage(game:get_value"sword_damage" / 2)
        local m = sol.movement.create("straight")
--        angle = 3* math.pi /2 + (math.random(-.3,.3))
        local angle = hero:get_angle(feather)
        angle = angle + math.random(-1.5,1.5)
        m:set_angle(angle)
        m:start(feather)
        sol.timer.start(map, 1000, function() feather:remove() end)
        return true
      end
    end)
  end

end

--come back!
function item:come_back(boomerang, speed)
  local m = sol.movement.create("target")
  m:set_ignore_obstacles(true)
  m:set_speed(speed+20)
  m:start(boomerang, function()
    boomerang:remove()
    item.can_throw = true
  end)
end

--smack enemy
function item:smack_enemy(enemy)
  local reaction = enemy:get_attack_consequence("boomerang")
  if reaction ~= "protected" and reaction ~= "ignored" then
    if not enemy.immobilize_immunity then
      enemy:immobilize()
    end
    local damage = {1, 5}
    damage = damage[item:get_variant()]
    enemy:hurt(damage)
  end
end
