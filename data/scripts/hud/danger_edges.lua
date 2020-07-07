local danger_edges = {}

local edge_blur

function danger_edges:on_started()
  edge_blur = sol.surface.create("hud/danger_edges.png")
  edge_blur:set_blend_mode("blend")
--  edge_blur:set_opacity(1)
  edge_blur:fade_in(5, function()
    edge_blur:fade_out(20, function()
      sol.menu.stop(danger_edges)
    end)
  end)
end

function danger_edges:on_draw(dst)
  edge_blur:draw(dst)
end

return danger_edges