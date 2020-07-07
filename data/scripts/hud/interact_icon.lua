local interact_icon_builder = {}

function interact_icon_builder:new(game, config)
  local icon  = {}
  icon.x = config.x
  icon.y = config.y
  icon.current_text = ""

  local icon_surface = sol.surface.create(48, 16)
  icon_surface:set_opacity(0)
  local icon_box = sol.surface.create("hud/interact_icon.png")
  icon_box:set_opacity(0)
  local icon_text = sol.text_surface.create{
    horizontal_alignment = "center",
    font = "enter_command", font_size = 16,
  }

  local function check()
    local effect = game:get_command_effect("action")
    if effect == "speak" then effect = "interact"
    elseif effect == "swim" then effect = nil
    end
    if effect ~= icon.current_text then
      icon.current_text = effect
      icon_surface:clear()
      icon_text:set_text(effect)
      if effect == nil then
        icon_surface:fade_out(5)
      else
        icon_surface:fade_in(5)
        icon_box:set_opacity(255) --don't make opaque until now otherwise you get 1 fame visible as game starts
      end
      icon_box:draw(icon_surface)
      icon_text:draw(icon_surface, 24, 8)
    end
    return true
  end


  function icon:on_draw(dst)
--[[    icon_surface:draw(dst, icon.x, icon.y)
    local hero = sol.main.get_game():get_hero()
    local x, y = hero:get_position()
    local camx, camy = sol.main.get_game():get_map():get_camera():get_position()
    local dx = { [0]=16, [1]=0, [2]=-16, [3]=0 }
    local dy = { [0]=0, [1]=-16, [2]=0, [3]=16 }
    x = x + dx[hero:get_direction()] - camx
    y = y + dy[hero:get_direction()] - camy
    icon_surface:draw(dst, x, y)
--]]
    icon_surface:draw(dst, icon.x, icon.y)
  end

  function icon:on_started()
    icon_surface:set_opacity(0)
    sol.timer.start(icon, 50, check)
  end

  return icon
end

return interact_icon_builder