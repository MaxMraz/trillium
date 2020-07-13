local manager = {}
local sounds = {}

function manager:play_sound(sound)
  if not sounds[sound] then
    sounds[sound] = true
    sol.audio.play_sound(sound)
    sol.timer.start(sol.main.get_game(), math.random(100,300), function()
      sounds[sound] = false
    end)
  end
end

return manager