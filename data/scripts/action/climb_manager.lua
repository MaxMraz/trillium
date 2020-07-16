local manager = {}
local SLOWDOWN = 45 --speed slowdown while climbing

  local state = sol.state.create("climbing")
  state:set_visible(true)
  state:set_can_control_direction(true)
  state:set_can_control_movement(true)
  state:set_gravity_enabled(false)
  state:set_can_come_from_bad_ground(false)
  state:set_can_be_hurt(false)
  state:set_can_use_sword(false)
  state:set_can_use_shield(false)
  state:set_can_use_item(false)
  state:set_can_interact(false)
  state:set_can_grab(false)
  state:set_can_push(false)
  state:set_can_pick_treasure(true)
  state:set_can_use_teletransporter(true)
  state:set_can_use_switch(true)
  state:set_can_use_stream(true)
  state:set_can_use_stairs(true)
  state:set_can_use_jumper(true)
  state:set_carried_object_action("throw")

function manager:get_state()
  return state
end

function state:on_started()
  local hero = state:get_map():get_hero()
  hero:set_walking_speed(hero:get_walking_speed() - SLOWDOWN)
end

function state:on_finished()
  local hero = state:get_map():get_hero()
  hero:set_walking_speed(hero:get_walking_speed() + SLOWDOWN)
end

return manager