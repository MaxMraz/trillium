--[[
Fog script, written by Max Mraz and Llamazing

Example usage:
  local fog1 = require("scripts/fx/fog").new()
  fog1:set_props{
  	fog_texture = {png = "fogs/fog.png", mode = "blend", opacity = 100},
  	opacity_range = {60,110},
    drift = {5, 0, -1, 1},
    parallax_speed = 1,
  }
  sol.menu.start(map, fog1)


--]]

local fog_manager = {}

function fog_manager.new()
	local fog_menu = {}

	--local surface = require("scripts/fx/lighting_effects"):get_shadow_surface()
	local surface = sol.surface.create()
	local width, height = surface:get_size()

	local opacity_min, opacity_max = 50, 150

	fog_menu.drift_x = 0
	fog_menu.drift_y = 0



	function fog_menu:set_props(props)
		fog_menu.drift = props and props.drift or {7, 0, -1, 1}
		fog_menu.parallax_speed = props and props.parallax_speed or 1
		fog_menu.texture = props and props.fog_texture or "fogs/fog.png"
		fog_menu.opacity_range = props and props.opacity_range or {60,100}

		fog_menu.props_set = true
	end


	function fog_menu:on_started()

		if not fog_menu.props_set then fog_menu:set_props() end
    sol.menu.bring_to_back(fog_menu) --so that it'll be behind the lighting_effects

		surface = sol.surface.create(fog_menu.texture.png or "fogs/fog.png")
		surface:set_blend_mode(fog_menu.texture.mode or "blend")
		surface:set_opacity(fog_menu.texture.opacity or 100)

		--Drift
		if fog_menu.drift[1] ~= 0 then
			sol.timer.start(fog_menu, 1000 / fog_menu.drift[1], function()
				fog_menu.drift_x = fog_menu.drift_x + 1 * (fog_menu.drift[3] or 1)
				return true
			end)
		end
		if fog_menu.drift[2] ~= 0 then
			sol.timer.start(fog_menu, 1000 / fog_menu.drift[2], function()
				fog_menu.drift_y = fog_menu.drift_y + 1 * (fog_menu.drift[4] or 1)
				return true
			end)
		end

		--Opacity Pulse
		opacity_decreasing = true
		opacity_step = 2
		if fog_menu.opacity_range then
			sol.timer.start(fog_menu, 150, function()
				local current_opacity = surface:get_opacity()
				if opacity_decreasing and current_opacity > fog_menu.opacity_range[1] then
					surface:set_opacity(current_opacity - opacity_step)
				elseif opacity_decreasing and current_opacity <= fog_menu.opacity_range[1] then
					opacity_decreasing = false
					surface:set_opacity(current_opacity + opacity_step)
				elseif current_opacity < fog_menu.opacity_range[2] then
					surface:set_opacity(current_opacity + opacity_step)
				elseif current_opacity >= fog_menu.opacity_range[2] then
					opacity_decreasing = true
					surface:set_opacity(current_opacity - opacity_step)
				end
				return true
			end)
		end
	end




	local function tile_draw(x_offset, y_offset, dst_surface, x, y)
	    local region_x = x_offset % width
	    local region_y = y_offset % height
	    
	    local region_width = width - region_x
	    local region_height = height - region_y
	    
	    --draw region 4
	    surface:draw_region(region_x, region_y, region_width, region_height, dst_surface, x, y)
	    
	    --draw region 3
	    if region_width>0 then
	        surface:draw_region(0, region_y, region_x, region_height, dst_surface, x+width-region_x, y)
	    end
	    
	    --draw region 2
	    if region_height>0 then
	        surface:draw_region(region_x, 0, region_width, region_y, dst_surface, x, y+height-region_y)
	    end
	    
	    --draw region 1
	    if region_width>0 and region_height>0 then
	        surface:draw_region(0, 0, region_x, region_y, dst_surface, x+width-region_x, y+height-region_y)
	    end
	end


	function fog_menu:on_draw(dst_surface)
	  local camera_x, camera_y = sol.main.get_game():get_map():get_camera():get_position()
	  tile_draw(
	  	fog_menu.drift_x + math.floor(camera_x * fog_menu.parallax_speed)%width,
	  	fog_menu.drift_y + math.floor(camera_y * fog_menu.parallax_speed)%height,
	  	dst_surface, 0, 0
	  	)
	end

	return fog_menu
end

return fog_manager