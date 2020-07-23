local map = ...
local game = map:get_game()

function light_switch:on_activated()
  map:open_doors"cave_door"
end