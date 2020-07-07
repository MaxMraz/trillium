require("scripts/multi_events")

local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
item:register_event("on_started", function(self)
  item:set_savegame_variable("possession_hookshot")
  item:set_assignable(true)
end)

-- Event called when the hero is using this item.
item:register_event("on_using", function(self)
  item:get_map():get_hero():start_hookshot()
  item:set_finished()
end)

-- Event called when a pickable treasure representing this item
-- is created on the map.
item:register_event("on_pickable_created", function(self, pickable)

  -- You can set a particular movement here if you don't like the default one.
end)
