local message_menu = {}

local text_surface = sol.text_surface.create()

function message_menu:show_message(string, duration)
  local game = sol.main.get_game()
--  text_surface:set_text_key(key)
  text_surface:set_text(string)
  sol.menu.start(game, message_menu)
  text_surface:fade_in()
  sol.timer.start(game, duration or 2800, function()
    text_surface:fade_out()
    text_surface:set_text("")
    sol.timer.start(game, 1000, function() sol.menu.stop(message_menu) end)
  end)
end

function message_menu:on_draw(dst)
  text_surface:draw(dst, 150, 10)
end

return message_menu