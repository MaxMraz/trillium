-- An icon that shows the inventory item assigned to a slot.

local item_icon_builder = {}

local background_img = sol.surface.create("hud/button_icon.png")

function item_icon_builder:new(game, config)

  local item_icon = {}

    item_icon.slot = config.slot or 1
    item_icon.surface = sol.surface.create(32, 32)
    item_icon.item_sprite = sol.sprite.create("entities/items")
    item_icon.item_amount = sol.text_surface.create{
        horizontal_alignment = "center",
        vertical_alignment = "top",
        font = "white_digits"
    }
    item_icon.item_displayed = nil
    item_icon.item_variant_displayed = 0
    item_icon.item_amount_displayed = 0

  local dst_x, dst_y = config.x, config.y

  function item_icon:rebuild_surface()
    item_icon.surface:clear()
    -- Background image.
    background_img:draw(item_icon.surface)

    if item_icon.item_displayed ~= nil then
      -- Item.
      item_icon.item_sprite:draw(item_icon.surface, 16, 20)
      item_icon.item_amount:draw(item_icon.surface, 19, 23)
    end
  end


  function item_icon:on_draw(dst_surface)

    local x, y = dst_x, dst_y
    local width, height = dst_surface:get_size()
    if x < 0 then
      x = width + x
    end
    if y < 0 then
      y = height + y
    end
    item_icon.surface:draw(dst_surface, x, y)
  end

  
  local function check()
    local need_rebuild = false
    -- Item assigned.
    local item = game:get_item_assigned(item_icon.slot)

    --if the displayed item's amount is different
    if item and item_icon.item_amount_displayed ~= item:get_amount() then
        need_rebuild = true
        item_icon.item_amount:set_text(item:get_amount())
        item_icon.item_amount_displayed = item:get_amount()
    end

    --if the item icon displayed isn't the equipped item
    if item_icon.item_displayed ~= item then
      need_rebuild = true
      item_icon.item_displayed = item
      item_icon.item_variant_displayed = nil
      if item ~= nil then
        item_icon.item_sprite:set_animation(item:get_name())
        if item:has_amount() then
            item_icon.item_amount:set_text(item:get_amount())
            item_icon.item_amount_displayed = item:get_amount()
        end
      end
    end

    if item ~= nil then
      -- Variant of the item.
      local item_variant = item:get_variant()
      if item_icon.item_variant_displayed ~= item_variant then
        need_rebuild = true
        item_icon.item_variant_displayed = item_variant
        item_icon.item_sprite:set_direction(item_variant - 1)
      end
    end

    -- Redraw the surface only if something has changed.
    if need_rebuild then
      item_icon:rebuild_surface()
    end

    return true  -- Repeat the timer.
  end

  -- Periodically check.
  check()
  sol.timer.start(game, 100, check)
  item_icon:rebuild_surface()

  function item_icon:on_paused()
    item_icon.surface:fade_out()
  end
  function item_icon:on_unpaused()
    item_icon.surface:fade_in()
  end

  return item_icon
end

return item_icon_builder


