local dash_manager = {}

local MAX_MOTHS = 15
local MAGIC_COST = 0
local enough_magic
local movement_id = 1
local current_movement

function dash_manager:dash(game)
    --if it consumes magic, make sure there's enough (doesn't consume magic anymore)
    enough_magic = false
    if game:get_value("can_warp_dash") and game:get_magic() >= MAGIC_COST then
        enough_magic = true
        game:remove_magic(MAGIC_COST)
    end

    --create movement
    local hero = game:get_hero()
    local dir = hero:get_direction()
    local dd = {[0]=0,[1]=math.pi/2,[2]=math.pi,[3]=3*math.pi/2} --to convert 0-4 direction to radians
    dir = dd[dir]
    local m = sol.movement.create("straight")
    m:set_angle(dir)
    if enough_magic then
        m:set_speed(300)
        m:set_max_distance(96)
    else
        m:set_speed(250)
        m:set_max_distance(64)
    end
    m:set_smooth(true)

    --set appropriate animation
    if enough_magic then
        hero:get_sprite():set_animation("dash", function() hero:get_sprite():set_animation("walking") end)
        game:set_value("hero_dashing", true)
        self:generate_moths(game)
    else
        hero:get_sprite():set_animation("roll", function() hero:get_sprite():set_animation("walking") end)
        game:set_value("hero_rolling", true)
    end
    if enough_magic then sol.audio.play_sound("dash")
    else sol.audio.play_sound("roll_2") end
    can_dash = false

    --create little dust clouds
    local x, y, z = hero:get_position()
    local map = hero:get_map()
    map:create_custom_entity({
      direction = 0, x = x, y = y, layer = z, width = 16, height = 16,
      sprite = "entities/dust_cloud_roll", model = "ephemeral_effect"
    })
    --this version does a couple little dust clouds
    local num_clouds = 3
    local cloud_delay = 100
    sol.timer.start(map, cloud_delay, function()
      for i = 1, num_clouds do
        local hx, hy, hz = hero:get_position()
        map:create_custom_entity({
          direction = 0, x = hx, y = hy, layer = hz, width = 16, height = 16,
          sprite = "entities/dust_cloud_roll", model = "ephemeral_effect"
        })
      end
    end)

    --start movement
    m:start(hero, function()
        hero:unfreeze()
        game:set_value("hero_dashing", false)
        game:set_value("hero_rolling", false)
    end)

    if enough_magic then hero:set_invincible(true, 400) end

    function m:on_obstacle_reached()
      hero:unfreeze()
      game:set_value("hero_dashing", false)
      game:set_value("hero_rolling", false)
    end


    hero:register_event("on_position_changed", function()
      if game:get_value("hero_dashing") or game:get_value("hero_rolling") then
        local ground = hero:get_ground_below()
        if ground == "deep_water" or ground == "hole" or ground == "lava" then
            m:stop()
        end
      end
    end)
end


function dash_manager:generate_moths(game)
  local map = game:get_map()
  local hero = game:get_hero()
  dash_manager.seeds = {}
  local n = 0
  sol.timer.start(map, math.random(10,30), function()
    local x, y, layer = game:get_hero():get_position()
    local sprite = sol.sprite.create"entities/dandelion_seed"
    dash_manager.seeds[sprite] = {
        x = x,
        y = y,
    }
    local m = sol.movement.create"random"
--    m:set_speed(80)
    m:start(dash_manager.seeds[sprite])
    sprite:set_animation("fade_out", function() dash_manager.seeds[sprite] = nil end)
    n = n + 1
    if n <= MAX_MOTHS then
      return true
    end
  end)
  --Moths return to Tilia as she stops dashing
  sol.timer.start(map, 240, function()
      for _, seed in pairs(dash_manager.seeds) do
        local m = sol.movement.create"target"
        m:set_target(hero:get_position())
        m:set_speed(200)
        m:start(seed)
      end
  end)


end

return dash_manager