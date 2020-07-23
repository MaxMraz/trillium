local item = ...
local game = item:get_game()

function item:on_started()
  item:set_savegame_variable("possession_bow_fire")
  item:set_assignable(true)
end

function item:on_using()
  local slot_assigned = (game:get_item_assigned(1) == item and 1 or 2)
  game:get_item("inventory/bow"):on_using({
    arrow_type = "electric",
    slot_assigned = slot_assigned
  })
end