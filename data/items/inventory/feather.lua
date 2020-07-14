local item = ...
local game = item:get_game()

local SPEED_BOOST = 10

-- Event called when all items have been created.
function item:on_started()
  item:set_savegame_variable("possession_feather")
  item:set_assignable(true)
end

function item:on_using()
  local hero = game:get_hero()
  local state = sol.state.create("jumping")
  state:set_can_control_direction(false)
  state:set_can_control_movement(true)
  state:set_can_traverse_ground("hole", true)
  state:set_can_traverse_ground("deep_water", true)
  state:set_can_traverse_ground("lava", true)
  state:set_affected_by_ground("hole", false)
  state:set_affected_by_ground("deep_water", false)
  state:set_affected_by_ground("lava", false)
  state:set_gravity_enabled(false)
  state:set_can_come_from_bad_ground(false)
  state:set_can_be_hurt(false)
  state:set_can_use_sword(false)
  state:set_can_use_item(false)
  state:set_can_interact(false)
  state:set_can_grab(false)
  state:set_can_push(false)
  state:set_can_pick_treasure(false)
  state:set_can_use_teletransporter(false)
  state:set_can_use_switch(false)
  state:set_can_use_stream(false)
  state:set_can_use_stairs(false)
  state:set_can_use_jumper(false)
  state:set_carried_object_action("throw")

  hero:set_animation("jumping_2")
  local shadow_sprite = hero:create_sprite("shadows/shadow_big")

  sol.audio.play_sound"jump"
  hero:set_walking_speed(hero:get_walking_speed() + SPEED_BOOST)
  hero:start_state(state)

  sol.timer.start(hero, 400, function()
    hero:set_animation"stopped"
    hero:remove_sprite(shadow_sprite)
    hero:set_walking_speed(hero:get_walking_speed() - SPEED_BOOST)
    hero:unfreeze()
  end)
  item:set_finished()
end
