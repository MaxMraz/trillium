-- The magic bar shown in the game screen.

local magic_bar_builder = {}

function magic_bar_builder:new(game, config)

  local magic_bar = {}

  magic_bar.dst_x, magic_bar.dst_y = config.x, config.y

  magic_bar.surface = sol.surface.create(120, 6)
  magic_bar.magic_bar_img = sol.surface.create("hud/magic_bar.png")
  magic_bar.magic_bar_background = sol.surface.create("hud/magic_bar_background.png")
  magic_bar.magic_displayed = game:get_magic()
--  magic_bar.max_magic_displayed = 0

  -- Checks whether the view displays the correct info
  -- and updates it if necessary.
  function magic_bar:check()

    local max_magic = game:get_max_magic()
    local magic = game:get_magic()

    -- Maximum magic.
    if max_magic ~= magic_bar.max_magic_displayed then
      if magic_bar.magic_displayed > max_magic then
        magic_bar.magic_displayed = max_magic
      end
      magic_bar.max_magic_displayed = max_magic
    end

    -- Current magic.
    if magic ~= magic_bar.magic_displayed then
      local increment
      if magic < magic_bar.magic_displayed then
        increment = -1
      elseif magic > magic_bar.magic_displayed then
        increment = 1
      end
      if increment ~= 0 then
        magic_bar.magic_displayed = magic_bar.magic_displayed + increment
      end
    end

    -- Schedule the next check.
    sol.timer.start(magic_bar, 20, function()
      magic_bar:check()
    end)
  end

  function magic_bar:get_surface()
    return magic_bar.surface
  end

  function magic_bar:on_draw(dst_surface)
    -- Is there a magic bar to show?
    if magic_bar.max_magic_displayed > 0 then
      local x, y = magic_bar.dst_x, magic_bar.dst_y
      local width, height = dst_surface:get_size()
      if x < 0 then
        x = width + x
      end
      if y < 0 then
        y = height + y
      end
      --draw background
      magic_bar.magic_bar_background:draw(dst_surface, x, y)
      -- Current magic. x, y, width, height, surface
      magic_bar.magic_bar_img:draw_region(0, 0, magic_bar.magic_displayed, 4, dst_surface, x, y)
    end
  end

  function magic_bar:on_started()
    magic_bar:check()
  end

  function magic_bar:on_paused()
    magic_bar.magic_bar_img:fade_out()
    magic_bar.magic_bar_background:fade_out()
  end
  function magic_bar:on_unpaused()
    magic_bar.magic_bar_img:fade_in()
    magic_bar.magic_bar_background:fade_in()
  end

  return magic_bar
end

return magic_bar_builder
