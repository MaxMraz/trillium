local possible_items = {
  "inventory/flame_spell",
  "inventory/spark_spell",
  "inventory/frostseed_satchel",
  "inventory/hookseed_satchel",
  "inventory/feather",
  "inventory/metal_block_cane",
  "inventory/hookshot",
  "inventory/boomerang",
  "inventory/bombs_counter",
  "inventory/bow",
  "inventory/bow_fire",
  "inventory/bow_ice",
  "inventory/bow_electric",
  "inventory/bow_bomb",
}

local menu = require("scripts/menus/inventory/bottomless_list"):build{
  all_items = possible_items,
  num_columns = 3,
  num_rows = 4,
}

function menu:init(game)
  function game:on_paused() sol.menu.start(game, menu) end
  function game:on_unpaused() sol.menu.stop(menu) end
end

menu:register_event("on_command_pressed", function(self, cmd)
  local game = sol.main.get_game()
  if cmd == "item_1" then
    local item = menu.held_items[menu.cursor_index + 1].item
    if game:get_item_assigned(1) ~= item then game:set_item_assigned(1, item) end

  elseif cmd == "item_2" then
    local item = menu.held_items[menu.cursor_index + 1].item
    if game:get_item_assigned(2) ~= item then game:set_item_assigned(2, item) end

  end
end)


return menu