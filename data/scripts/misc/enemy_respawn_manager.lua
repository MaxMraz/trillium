local manager = {}

function manager:manage_spawns(map)
  local game = map:get_game()
  local map_id = map:get_id()

  --Set empty array for saving enemy respawn data if there isn't one yet
  if not game.enemies_killed then game.enemies_killed = {} end
  if not (game.enemies_killed[map_id]) then game.enemies_killed[map_id] = {} end

  --Give enemies a unique ID based on their position
  for enemy in map:get_entities_by_type"enemy" do
    local x, y, z = enemy:get_position()
    --create a unique ID for each enemy based on starting position
    --This will fall apart if multiple enemies start in the same location
    local c_id = x .. "," .. y .. "," .. z

    --Save enemies to table when killed
    enemy:register_event("on_dying", function()
      game.enemies_killed[map_id][c_id] = {x=x, y=y, z=z}
    end)

  --Remove enemies that have already been killed
    if game.enemies_killed[map_id][c_id] then
      enemy:set_enabled(false)
    end
  end

end


return manager