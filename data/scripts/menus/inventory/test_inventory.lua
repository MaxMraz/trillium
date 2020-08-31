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
  num_rows = 3,
  num_columns = 3,
}

function menu:init(game)
  function game:on_paused() sol.menu.start(game, menu) end
  function game:on_unpaused() sol.menu.stop(menu) end
end


return menu