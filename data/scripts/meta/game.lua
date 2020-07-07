require"scripts/multi_events"

local game_meta = sol.main.get_metatable"game"

function game_meta:dx(offset)
  return {[0] = offset, [1] = 0, [2] = offset * -1, [3] = 0}
end

function game_meta:dy(offset)
  return {[0] = 0, [1] = offset * -1, [2] = 0, [3] = offset}
end

return game_meta