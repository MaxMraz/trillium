-- Defines the elements to put in the HUD
-- and their position on the game screen.

-- You can edit this file to add, remove or move some elements of the HUD.

-- Each HUD element script must provide a method new()
-- that creates the element as a menu.
-- See for example scripts/hud/hearts.lua.

-- Negative x or y coordinates mean to measure from the right or bottom
-- of the screen, respectively.

local hud_config = {

  -- Hearts meter.
  {
    menu_script = "scripts/hud/hearts",
    x = 5,
    y = -250,
  },

    --magic meter
    {
      menu_script = "scripts/hud/magic_bar",
      x = 5,
      y = 1,
    },

  --[[ Rupee counter.
  {
    menu_script = "scripts/hud/rupees",
    x = 386,
    y = 220,
  },
--]]


  -- Item assigned to slot 1.
  {
    menu_script = "scripts/hud/item",
    x = 360,
    y = 1,
    slot = 1,  -- Item slot (1 or 2).
  },



 -- Item assigned to slot 2.
  {
    menu_script = "scripts/hud/item",
    x = 383,
    y = 8,
    slot = 2,  -- Item slot (1 or 2).
  },



 -- Consumables picked-up.
  {
    menu_script = "scripts/hud/consumables",
    id = "consumables",
    x = -52,
    y = 48,
    duration = 2500,
  },

  --Interaction Icon
  {
    menu_script = "scripts/hud/interact_icon",
    x = 4, y = 222,
  },
}

return hud_config
