-- Sets up all non built-in gameplay features specific to this quest.

-- Usage: require("scripts/features")

-- Features can be enabled to disabled independently by commenting
-- or uncommenting lines below.

require"scripts/multi_events"

require"scripts/action/swim_manager"
require"scripts/hud/hud"
require"scripts/menus/dialog_box"
require"scripts/meta/bush"
require"scripts/meta/camera"
require"scripts/meta/game"
require"scripts/meta/hero"
require"scripts/meta/map"
require"scripts/meta/map_elemental_effects"
require"scripts/misc/solid_ground_manager"

return true
