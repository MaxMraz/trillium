local menu = {}

function menu:init(game)
  function game:on_paused() sol.menu.start(game, menu) end
  function game:on_unpaused() sol.menu.stop(menu) end
end

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

local held_items = {} --will look same as possible_items table, minus unobtained items
local item_sprites = {} --example { "boomerang" = sprite-userdata, "sword" = differentsprite, etc}

local cursor_index = 1

local cursor_sprite = sol.sprite.create("menus/arrow")
cursor_sprite:set_direction(1)
local item_square = sol.surface.create(24, 24)
item_square:fill_color{40,40,40}
item_square:set_opacity(150)

local equipped_item_1_sprite = sol.sprite.create("entities/items")
equipped_item_1_sprite:set_animation"empty"
local equipped_item_2_sprite = sol.sprite.create("entities/items")
equipped_item_2_sprite:set_animation"empty"

function menu:on_started()
  local game = sol.main.get_game()
  --Clear tables to prevent duplication
  held_items = {}
  item_sprites = {}

  for _, item_name in pairs(possible_items) do
    if game:get_item(item_name):get_variant() > 0 then
      table.insert(held_items, item_name)
      item_sprites[item_name] = sol.sprite.create("entities/items")
      item_sprites[item_name]:set_animation(item_name)
      item_sprites[item_name]:set_direction(game:get_item(item_name):get_variant() - 1)
    end
  end

  menu:update_equipped_item_sprites()

end


function menu:update_equipped_item_sprites()
  local game = sol.main.get_game()
  if game:get_item_assigned(1) then
    equipped_item_1_sprite:set_animation(game:get_item_assigned(1):get_name())
    equipped_item_1_sprite:set_direction(game:get_item_assigned(1):get_variant() - 1)
  end
  if game:get_item_assigned(2) then
    equipped_item_2_sprite:set_animation(game:get_item_assigned(2):get_name())
    equipped_item_2_sprite:set_direction(game:get_item_assigned(2):get_variant() - 1)
  end
end


function menu:on_command_pressed(cmd)
  local game = sol.main.get_game()

  if cmd == "right" then
    cursor_index = (cursor_index + 1)
    if cursor_index > #held_items then cursor_index = 1 end

  elseif cmd == "left" then
    cursor_index = (cursor_index - 1)
    if cursor_index < 1 then cursor_index = #held_items end

  elseif cmd == "item_1" then
    game:set_item_assigned(1, game:get_item(held_items[cursor_index]))
    menu:update_equipped_item_sprites()

  elseif cmd == "item_2" then
    game:set_item_assigned(2, game:get_item(held_items[cursor_index]))
    menu:update_equipped_item_sprites()

  end
end



--local SPACING = 32
local SPACING = 24
function menu:on_draw(dst)
  for i, item_name in ipairs(held_items) do
    item_square:draw(dst, i * SPACING, 140)
    item_sprites[item_name]:draw(dst, i * SPACING + 12, 156)
  end
  cursor_sprite:draw(dst, 8 + SPACING * (cursor_index or 1), 170)
  equipped_item_1_sprite:draw(dst, 200, 20)
  equipped_item_2_sprite:draw(dst, 224, 20)
end


return menu