local hero_meta = sol.main.get_metatable("hero")

--Shadow
hero_meta:register_event("on_created", function(self)
  local hero = self
  local shadow = hero:create_sprite("shadows/shadow_medium", "custom_shadow")
  hero:bring_sprite_to_back(shadow)

  hero:register_event("on_state_changed", function(self, state)
    if state == "boomerang"
    or state == "bow"
    or state == "carrying"
    or state == "forced walking"
    or state == "free"
    or state == "frozen"
    or state == "grabbing"
    or state == "hookshot"
    or state == "hurt"
    or state == "lifting"
    or state == "plunging"
    or state == "pulling"
    or state == "pushing"
    or state == "running"
    or state == "stairs"
    or state == "sword loading"
    or state == "sword spin attack"
    or state == "sword swinging"
    or state == "sword tapping"
    or state == "treasure"
    or state == "using item"
    or state == "victory"
    then
      --Show shadow
      shadow:set_opacity(255)

    elseif state == "back to solid ground"
    or state == "falling"
    or state == "jumping"
    or state == "swimming"
    then
      shadow:set_opacity(0)

    elseif state == "custom" then

    else


    end
  end)

end)
