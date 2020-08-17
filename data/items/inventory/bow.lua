local item = ...
local game = item:get_game()

local SPEED_DELTA = 40

function item:on_started()
  item:set_savegame_variable("possession_bow")
  item:set_assignable(true)
end

function item:on_using(props)
  local arrow_type = (props and props.arrow_type) or nil
  local map = item:get_map()
  local hero = map:get_hero()
  local slot_assigned = (props and props.slot_assigned) or (game:get_item_assigned(1) == item and 1 or 2)

  hero:set_animation("bow_draw", function()
    hero:set_animation"bow_drawn"
    hero:start_state(item:get_bow_state())
    hero:set_walking_speed(hero:get_walking_speed() - SPEED_DELTA)
    sol.timer.start(hero,10,function()
      if game:is_command_pressed("item_" .. slot_assigned) then
        return true
      else
        item:fire(arrow_type)
        hero:set_animation("bow_fire", function()
          hero:set_walking_speed(hero:get_walking_speed() + SPEED_DELTA)
          hero:unfreeze()
          item:set_finished()
        end)
      end
    end)
  end)

end


function item:fire(arrow_type)
  local map = item:get_map()
  local hero = map:get_hero()
  local dir4 = hero:get_direction()
  local x, y, z = hero:get_position()
  local aw = {[0] = 16, [1] = 8, [2] = 16, [3] = 8}
  local ah = {[0] = 8, [1] = 16, [2] = 8, [3] = 16}
  local arrow = map:create_custom_entity{
    x = x + game:dx(16)[dir4], y = y + game:dy(16)[dir4] - 2, layer = z,
    width = aw[dir4], height = ah[dir4],
    direction = dir4,
    model = "arrow_player",
  }

  if arrow_type then arrow:apply_type(arrow_type) end
  arrow:fire(dir4)

end



function item:get_bow_state()
  local state = sol.state.create()
  state:set_visible(true)
  state:set_can_control_direction(false)
  state:set_can_control_movement(true)
  state:set_gravity_enabled(true)
  state:set_can_come_from_bad_ground(true)
  state:set_can_be_hurt(true)
  state:set_can_use_sword(false)
  state:set_can_use_shield(false)
  state:set_can_use_item(false)
  state:set_can_interact(false)
  state:set_can_grab(false)
  state:set_can_push(false)
  state:set_can_pick_treasure(true)
  state:set_can_use_teletransporter(false)
  state:set_can_use_switch(true)
  state:set_can_use_stream(true)
  state:set_can_use_stairs(false)
  state:set_can_use_jumper(false)
  state:set_carried_object_action("throw")
  return state
end