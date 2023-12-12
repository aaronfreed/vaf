-- Vasara 1.0.4 (Script)
-- by Hopper and Ares Ex Machina, Aaron Freed, CryoS, and Solra Bizna
-- from work by Jon Irons and Gregory Smith, released under the JUICE LICENSE!

-- preferences now begin on line 154 - the following code must execute first

-- Copyright 2023 Solra Bizna. I expressly authorize you (the reader) to use
-- this script, change it to fit your needs, strip out my name and claim it as
-- your own, whatever. This copyright claim is solely to assert authorship long
-- enough to immediately disclaim all copy-rights.

load_order = load_order or {}
table.insert(load_order, "Vasara_Script.lua")

-- Part 0: Don't let me call pairs() [by accident]. I hate pairs().

_G.danger_pairs = pairs
pairs = nil

-- Part 1: Create a system that allows triggers to be created cooperatively.
-- AND some safety stuff that will make it so that we won't do things the old
-- way by accident and ruin everything.

local shadow_triggers = {}
local the_real_triggers = {}
local subtriggers = {}

Triggers = nil

setmetatable(_G, {
	__index = {Triggers = shadow_triggers},
	__newindex = function(t, key, value)
		if key == "Triggers" then
			for key, value in danger_pairs(value) do
				shadow_triggers[key] = value
			end
		else
			rawset(_G, key, value)
		end
	end,
})

setmetatable(shadow_triggers, {
	__index = the_real_triggers,
	__newindex = function(t, key, value)
		if the_real_triggers[key] == nil then
			the_real_triggers[key] = function(...)
				local ret = true
				for _, subtrigger in ipairs(subtriggers[key]) do
					local success, result
					if debug and debug.traceback and xpcall then
						success, result = xpcall(subtrigger, debug.traceback, ...)
					else
						success, result = pcall(subtrigger, ...)
					end
					if not success then
						-- There was a message. Print the error message.
						print("Error in Triggers."..key..":\n"..result)
					elseif result == false then
						-- If the subtrigger explicitly returned false, don't call
						-- any more subtriggers.
						ret = false
						break
					end
				end
				return ret
			end
		end
		if subtriggers[key] == nil then
			subtriggers[key] = {}
		end
		table.insert(subtriggers[key], value)
	end,
	__call = function(me, t)
		for key, value in danger_pairs(t) do
			me[key] = value
		end
	end,
})

-- Part 2: Make print print *both* to the command line *and* to the screen,
-- even in Triggers.init(), even in the top level.

local messages_to_print_on_first_idle = {}
local real_print = print
function print(...)
	-- print prints its arguments separated by tabs
	local text = table.concat({...}, "\t")
	real_print(text)
	if messages_to_print_on_first_idle ~= nil then
		table.insert(messages_to_print_on_first_idle, text)
	else
		Players.print(text)
	end
end

function Triggers.idle()
	if messages_to_print_on_first_idle ~= nil then
		for _, message in ipairs(messages_to_print_on_first_idle) do
			Players.print(message)
		end
		messages_to_print_on_first_idle = nil
	end
end

-- Part 3: There's no downside to calling the restore_* functions if they're
-- not needed. They need to be called EXACTLY once per init() if they are
-- needed. So let's call them ourselves, and cache the result, so that other
-- triggers can still call them as normal and have them work as expected.
--
-- Bonus: make it so that calling the wrong restoration function throws an
-- error.

-- Part 3: There's no downside to calling the restore_* functions if they're
-- not needed. They need to be called EXACTLY once per init() if they are
-- needed. So let's call them ourselves, and cache the result, so that other
-- triggers can still call them as normal and have them work as expected.
--
-- Bonus: make it so that calling the wrong restoration function throws an
-- error.

function Triggers.init(restoring_game)
	local RealGame = Game
	Game = {}
	if restoring_game then
		local restore_result = RealGame.restore_saved()
		function Game.restore_saved()
			if Level.stash["debug"] then
				print("Game.restore_saved() has been cached")
			end
			return restore_result
		end
		function Game.restore_passed()
			error("Game.restore_passed() called, but we were loading from a save!")
		end
	else
		local restore_result = RealGame.restore_passed()
		function Game.restore_passed()
			if Level.stash["debug"] then
				print("Game.restore_passed() has been cached")
			end
			return restore_result
		end
		function Game.restore_saved()
			error("Game.restore_saved() called, but we were not loading from a save!")
		end
	end
	setmetatable(Game, {
		__index=RealGame,
		__newindex=RealGame,
	})
end

-- PREFERENCES

WALLS = { 17, 18, 19, 20, 21 }
LANDSCAPES = { 27, 28, 29, 30 }

SUPPRESS_ITEMS = true
SUPPRESS_MONSTERS = true

MAX_TAGS = 90     -- max: 90
MAX_SCRIPTS = 90  -- max: 90

-- set to false to hide the Visual Mode header on startup
SHOW_VISUAL_MODE_HEADER = true

-- highlight selected destination in Teleport mode
SHOW_TELEPORT_DESTINATION = true

-- cursor speed settings: larger numbers mean a slower mouse
MENU_VERTICAL_RANGE = 30      -- default: 30
MENU_HORIZONTAL_RANGE = 70    -- default: 70
DRAG_VERTICAL_RANGE = 80      -- default: 80
DRAG_HORIZONTAL_RANGE = 120   -- default: 120

-- how far you can drag a texture before it stops moving (in World Units)
DRAG_VERTICAL_LIMIT = 1
DRAG_HORIZONTAL_LIMIT = 1

-- how many ticks before you start dragging a texture
DRAG_INITIAL_DELAY = 3

-- how many ticks between fast forward/rewind steps
FFW_INITIAL_DELAY = 5
FFW_REPEAT_DELAY = 0
FFW_TEXTURE_SCRUB_SPEED = 0
FFW_TELEPORT_SCRUB_SPEED = 1

-- how many ticks to highlight a latched keypress in HUD
KEY_HIGHLIGHT_DELAY = 4

-- which menu items should be in what state when Vasara starts up
APPLY_TEXTURES = true
APPLY_LIGHTS = false
ALIGN_ADJACENT = true
REALIGN_WHEN_RETEXTURING = false
EDIT_PANELS = true
APPLY_TRANSPARENT = false
APPLY_TRANSFER = true
QUANTIZE_MODE = 3 -- 1 = negative, 2 = positive, 3 = relative. i'm sorry about this order
QUANTIZE_X = true
QUANTIZE_Y = true -- set both to false to disable grid snap
DEFAULT_QUANTIZE = 8 -- see snap_denominators below for possible options here: first menu option is 1, second is 2, third is 3, etc

-- END PREFERENCES -- no user serviceable parts below ;)


MAX_LIGHTS = 98 -- maximum number of lights we can accommodate

Game.monsters_replenish = not SUPPRESS_MONSTERS
snap_denominators = { 2, 3, 4, 5, 6, 8, 10, 16, 20, 24, 32, 128 }
snap_modes = {}
for _,d in ipairs(snap_denominators) do
	table.insert(snap_modes, string.format("1/%d WU",d))
end
transfer_modes = {
	TransferModes["normal"], TransferModes["pulsate"],
	TransferModes["wobble"], TransferModes["fast wobble"],
	TransferModes["static"], TransferModes["landscape"],
	TransferModes["horizontal slide"], TransferModes["fast horizontal slide"],
	TransferModes["vertical slide"], TransferModes["fast vertical slide"],
	TransferModes["wander"], TransferModes["fast wander"],
	TransferModes["reverse horizontal slide"], TransferModes["reverse fast horizontal slide"],
	TransferModes["reverse vertical slide"], TransferModes["reverse fast vertical slide"],
	TransferModes["2x"], TransferModes["4x"]
}
transfer_mode_lookup = {}
for k, v in danger_pairs(transfer_modes) do transfer_mode_lookup[v] = k - 1 end

CollectionsUsed = {}
for _, collection in danger_pairs(WALLS) do
	table.insert(CollectionsUsed, collection)
end
for _, collection in danger_pairs(LANDSCAPES) do
	table.insert(CollectionsUsed, collection)
end

Triggers = {}
function init()
	VML.init()

	for p in Players() do
		p.weapons.active = false

		local pal = p.texture_palette
		pal.highlight = 0
		if p.local_ then
			local colldef = Collections[0]
			local typedef = TextureTypes["interface"]
			pal.size = 256
			for s = 0,31 do
				local slot = pal.slots[s]
				slot.collection = colldef
				slot.texture_index = 0
				slot.type = typedef
			end
		end
	end

	if SUPPRESS_ITEMS then
		for item in Items() do
			item:delete()
		end

		function Triggers.item_created(item)
			item:delete()
		end
	end

	SKeys.init()
	SCollections.init()
	SPanel.init()
	SPlatforms.init()
	SFreeze.init()
	SMode.init()
	SUndo.init()

	inited_script = true
end

function Triggers.idle()
	if not Sides.new then
		Players.print("Vasara requires a newer version of Aleph One")
		kill_script()
		return
	end

	if not inited_script then init() end

	SKeys.update()
	SCounts.update()
	SLights.update()
	SPlatforms.update()
	SFreeze.update()
	SMode.update()
	SUndo.update()
	SStatus.update()
	SCollections.update()
	SPanel.update()

	for p in Players() do
		p.life = 450
		p.oxygen = 10800
		VML.find_target(p, false, false)
	end

	if Level.stash["ERROR"] ~= nil then
		print(Level.stash["ERROR"])
		Level.stash["ERROR"] = nil
	end
end

function Triggers.postidle()
	SFreeze.postidle()
	for p in Players() do
		p.life = 409 -- signal to HUD that Vasara is active
	end
end

function Triggers.terminal_enter(terminal, player)
	if terminal then
		player._terminal = true
	end
end

function Triggers.terminal_exit(_, player)
	player._terminal = false
end

function Triggers.player_damaged(p, ap, am, dt, da, pr)
	p.life = 450
	p.oxygen = 10800
end

function Triggers.cleanup()
	for p in Players() do
		if p._teleport.last_target ~= nil then
			uTeleport.remove_highlight(p)
		end
	end
end

function PIN(v, min, max)
	if v < min then return min end
	if v > max then return max end
	return v
end

SMode = {
	apply = 0,
	choose = 1,
	attribute = 2,
	teleport = 3,
	panel = 4,

	init = function()
		for p in Players() do
			p._mode = SMode.apply
			p._prev_mode = SMode.apply
			p._mic_dummy = false
			p._target_poly = 0
			p._quantize = 0
			p._quantize_x = QUANTIZE_X
			p._quantize_y = QUANTIZE_Y
			p._menu_button = nil
			p._menu_item = 0
			p._cursor_x = 320
			p._cursor_y = 240
			p._advanced_mode = not SHOW_VISUAL_MODE_HEADER

			SMode.default_attribute(p)

			p._teleport = {
				last_target = nil,
				last_target_mode = nil,
			}

			p._panel = {
				editing = false,
				classnum = 0,
				permutation = 0,
				light_dependent = false,
				only_toggled_by_weapons = false,
				repair = false,
				status = false,
				surface = nil,
				sides = {},
				dinfo = nil,
			}

			p._saved_facing = {
				direction = 0,
				elevation = 0,
				x = 0,
				y = 0,
				z = 0,
				just_set = false,
			}

			p._saved_surface = {
				surface = nil,
				polygon = nil,
				x = 0,
				y = 0,
				dragstart = 0,
				align_table = nil,
				offset_table = nil,
				opposite_surface = nil,
				opposite_offsets = nil,
				opposite_rem = 0,
			}

	-- 		p._annotation = Annotations.new(Polygons[0], "")

			if p.local_ then
				p.texture_palette.slots[40].texture_index = p._mode
			end
		end
	end,

	current_menu_name = function(p)
		if p._mode == SMode.attribute then
			return SMode.attribute
		elseif p._mode == SMode.choose then
			return "choose_" .. p._collections.current_collection
		elseif p._mode == SMode.panel then
			return SPanel.menu_name(p)
		end
		return nil
	end,

	update = function()
		for p in Players() do

			p._prev_mode = p._mode

			-- process mode actions
			if p._mode == SMode.apply then
				SMode.handle_apply(p)
			elseif p._mode == SMode.teleport then
				SMode.handle_teleport(p)
			elseif p._mode == SMode.choose then
				SMode.handle_choose(p)
			elseif p._mode == SMode.attribute then
				SMode.handle_attribute(p)
			elseif p._mode == SMode.panel then
				SMode.handle_panel(p)
			end

			-- handle mode switches
			if not p._keys.mic.down then
				if p._keys.map.pressed then
					if p._overhead then
						p._mode = SMode.teleport
					else
						p._mode = SMode.apply
					end
				elseif p._keys.action.pressed then
					-- only allow default action trigger in apply and teleport
					if (p._mode ~= SMode.teleport and p._mode ~= SMode.apply) or (not p:find_action_key_target()) then
						p.action_flags.action_trigger = false
						SMode.toggle(p, SMode.attribute)
					end
				elseif p._keys.mic.released and (not p._mic_dummy) then
					SMode.toggle(p, SMode.choose)
				elseif p._keys.secondary.released and p._mode ~= SMode.apply then
					SMode.toggle(p, p._mode)
				end
			end

			-- track mic-as-modifier, and don't switch if we use that
			if p._keys.mic.down then
				if p._keys.prev_weapon.down or p._keys.next_weapon.down or p._keys.action.down or p._keys.primary.down or p._keys.primary.released or p._keys.secondary.down or p._keys.secondary.released then
					p._mic_dummy = true
				end
			elseif p._keys.mic.released then
				p._mic_dummy = false
			end

			local in_menu = SMode.menu_mode(p._mode)

			if p._mode ~= p._prev_mode then
				p._menu_button = nil
				p._menu_item = 0
				local was_menu = SMode.menu_mode(p._prev_mode)

				-- special cleanup for exiting modes
				if p._prev_mode == SMode.teleport then
					UTeleport.remove_highlight(p)
				elseif p._prev_mode == SMode.panel then
					SPanel.stop_editing(p)
				end

				-- special setup for entering modes
				if p._mode == SMode.attribute then
					SMode.start_attribute(p)
				end

				if in_menu then
					SFreeze.enter_mode(p, "menu")
				else
					SFreeze.enter_mode(p, nil)
				end
			end

			if p.local_ then
				p.texture_palette.slots[37].texture_index = p._target_poly % 128
				p.texture_palette.slots[38].texture_index = math.floor(p._target_poly/128)
				p.texture_palette.slots[40].texture_index = p._mode

				-- set cursor
				if in_menu then
					p._cursor_x, p._cursor_y = SFreeze.coord(p)
				elseif p._mode == SMode.apply then
					p._cursor_x = 320
					p._cursor_y = 72 + 160
					if p._advanced_mode then p._cursor_y = 196 end
					if SFreeze.in_mode(p, "drag") then
						local delta_yaw, delta_pitch
						delta_yaw, delta_pitch = SFreeze.coord(p)
						p._cursor_x = p._cursor_x + math.floor(delta_yaw * 300.0/1024.0)
						p._cursor_y = p._cursor_y + math.floor(delta_pitch * 140.0/1024.0)
					end
				elseif p._mode == SMode.teleport then
					p._cursor_x = 320
					p._cursor_y = math.floor((3*72 + 480)/4)
					if p._advanced_mode then p._cursor_y = 480/4 end
				end
			end
		end
	end,

	menu_mode = function(mode)
		return mode == SMode.choose or mode == SMode.attribute or mode == SMode.panel
	end,

	toggle = function(p, mode)
		if p._mode == mode then
			p._mode = SMode.apply
		else
			p._mode = mode
		end
		if p._overhead then
			p.action_flags.toggle_map = true
			p._overhead = false
		end
	end,

	handle_apply = function(p)
		local clear_surface = true

		if p._keys.mic.down then
			if p._keys.next_weapon.held then
				SFreeze.unfreeze(p)
				p:accelerate(0, 0, 0.05)
			elseif p._keys.prev_weapon.pressed then
				SFreeze.toggle_freeze(p)
			end
		else
			if p._keys.primary.down then
				-- apply
				clear_surface = false
				local surface = p._saved_surface.surface
				if p._keys.primary.pressed then
					surface, polygon = SCollections.find_surface(p, false)
					local coll = p._collections.current_collection
					local landscape = false
					if coll == 0 then
						coll = p._collections.current_landscape_collection
						landscape = true
					end
					local tex = p._collections.current_textures[coll]

					p._saved_surface.surface = surface
					p._saved_surface.opposite_surface = nil
					p._saved_surface.polygon = polygon
					if (not p._apply.texture) or (surface.collection and ((coll == surface.collection.index) and (tex == surface.texture_index)) or not p._apply.realign) then
						p._saved_surface.x = surface.texture_x
						p._saved_surface.y = surface.texture_y
					else
						p._saved_surface.x = 0
						if is_side(o) then
							local bottom, top = VML.surface_heights(surface)
							p._saved_surface.y = bottom - top
						else
							p._saved_surface.y = 0
						end
					end
					p._saved_surface.dragstart = Game.ticks

					SUndo.add_undo(p, surface)
					UApply.apply_texture(p, surface, coll, tex, landscape)
					if is_transparent_side(surface) then
						-- put the same texture on the opposite side of the line
						local dsurface = nil
						local side = Sides[surface.index]
						local line = side.line
						if line.clockwise_side == side then
							if line.counterclockwise_side then
								dsurface = line.counterclockwise_side.transparent
							elseif line.counterclockwise_polygon then
								dsurface = Sides.new(line.counterclockwise_polygon, line).transparent
							end
						else
							if line.clockwise_side then
								dsurface = line.clockwise_side.transparent
							elseif line.clockwise_polygon then
								dsurface = Sides.new(line.clockwise_polygon, line).transparent
							end
						end

						if dsurface then
							SUndo.add_undo(p, dsurface)
							UApply.apply_texture(p, dsurface, coll, tex, landscape)
							local rem = line.length - math.floor(line.length)
							dsurface.texture_x = 0 - dsurface.texture_x - rem
							p._saved_surface.opposite_surface = dsurface
							p._saved_surface.opposite_rem = rem
						end
					end

					if p._apply.align then
						if is_polygon_floor(surface) or is_polygon_ceiling(surface) then
							p._saved_surface.align_table = VML.build_polygon_align_table(polygon, surface)
							local is_floor = is_polygon_floor(surface)
							for s in danger_pairs(p._saved_surface.align_table) do
								if is_floor then
									SUndo.add_undo(p, s.floor)
								else
									SUndo.add_undo(p, s.ceiling)
								end
							end
							VML.align_polygons(surface, p._saved_surface.align_table)
						else
							p._saved_surface.offset_table = VML.build_side_offsets_table(surface)
							for s in danger_pairs(p._saved_surface.offset_table) do
								SUndo.add_undo(p, s)
							end
							VML.align_sides(surface, p._saved_surface.offset_table)

							local dsurface = p._saved_surface.opposite_surface
							if dsurface then
								local doffsets = VML.build_side_offsets_table(dsurface)
								p._saved_surface.opposite_offsets = doffsets
								for s in danger_pairs(doffsets) do
									SUndo.add_undo(p, s)
								end
								VML.align_sides(dsurface, doffsets)
							end
						end
					end

				elseif surface and (Game.ticks > p._keys.primary.first + DRAG_INITIAL_DELAY) then
					SFreeze.enter_mode(p, "drag")

					local delta_yaw, delta_pitch
					delta_yaw, delta_pitch = SFreeze.coord(p)
					delta_yaw = delta_yaw / 1024.0
					delta_pitch = delta_pitch / 1024.0

					if is_polygon_floor(surface) or is_polygon_ceiling(surface) then
						if is_polygon_ceiling(surface) then delta_pitch = -delta_pitch end

						local orad = math.rad(SFreeze.orig_dir(p))
						local xoff = delta_pitch * math.cos(orad) + delta_yaw * math.sin(orad)
						local yoff = delta_pitch * math.sin(orad) - delta_yaw * math.cos(orad)

						local dx = p._saved_surface.x + xoff
						local dy = p._saved_surface.y + yoff

						if p._apply.quantize_mode == 1 or p._apply.quantize_mode == 2 then
							if p._quantize_x then surface.texture_x = VML.quantize(p, dx) else surface.texture_x = dx end
							if p._quantize_y then surface.texture_y = VML.quantize(p, dy) else surface.texture_y = dy end
						elseif p._apply.quantize_mode == 3 then
							if p._quantize_x then
								surface.texture_x = VML.quantize_polygon_center(p, dx, Polygons[surface.index].x)
							else
								surface.texture_x = dx
							end
							if p._quantize_y then
								surface.texture_y = VML.quantize_polygon_center(p, dy, Polygons[surface.index].y)
							else
								surface.texture_y = dy
							end
						end

						if p._apply.align then
							VML.align_polygons(surface, p._saved_surface.align_table)
						end
					else
						local dx = p._saved_surface.x - delta_yaw
						local dy = p._saved_surface.y - delta_pitch
						if p._apply.quantize_mode == 1 then
							if p._quantize_x then
								surface.texture_x = VML.quantize_right(p, dx, Sides[surface.index])
							else
								surface.texture_x = dx
							end
							if p._quantize_y then
								surface.texture_y = VML.quantize(p, dy)
							else
								surface.texture_y = dy
							end
						elseif p._apply.quantize_mode == 2 then
							if p._quantize_x then
								surface.texture_x = VML.quantize(p, dx)
							else
								surface.texture_x = dx
							end
							if p._quantize_y then
								surface.texture_y = VML.quantize(p, dy)
							else
								surface.texture_y = dy
							end
						elseif p._apply.quantize_mode == 3 then
							if p._quantize_x then
								surface.texture_x = VML.quantize_side_center_x(p, dx, Sides[surface.index])
							else
								surface.texture_x = dx
							end
							if p._quantize_y then
								surface.texture_y = VML.quantize(p, dy)
							else
								surface.texture_y = dy
							end
						end

						if p._apply.align then
							VML.align_sides(surface, p._saved_surface.offset_table)
						end

						local dsurface = p._saved_surface.opposite_surface
						if dsurface then
							dsurface.texture_x = 0 - surface.texture_x - p._saved_surface.opposite_rem
							dsurface.texture_y = surface.texture_y
							if p._apply.align then
								VML.align_sides(dsurface, p._saved_surface.opposite_offsets)
							end
						end
					end
				end
			elseif p._keys.primary.released then
				-- release any drag
				SFreeze.enter_mode(p, nil)

				-- are we editing control panels
				if p._apply.texture and p._apply.edit_panels and is_primary_side(p._saved_surface.surface) then
					if SPanel.surface_can_hold_panel(p._saved_surface.surface) then
						-- valid for control panels; configure it
						SPanel.start_editing(p, p._saved_surface.surface)
						if p._apply.align then
							for s in danger_pairs(p._saved_surface.offset_table) do
								SPanel.add_for_editing(p, s)
							end
						end
						clear_surface = false
						SMode.toggle(p, SMode.panel)
					else
						-- not a valid texture for control panels; clear it
						Sides[p._saved_surface.surface.index].control_panel = false
						if p._apply.align then
							for s in danger_pairs(p._saved_surface.offset_table) do
								Sides[s.index].control_panel = false
							end
						end
					end
				end
			elseif p._keys.secondary.released then
				-- sample
				local surface = SCollections.find_surface(p, true)
				if surface and (not (is_transparent_side(surface) and surface.empty)) then
					SCollections.set(p, surface.collection.index, surface.texture_index)
					if p._collections.current_collection ~= 0 then
						p._light = surface.light.index
						p._transfer_mode = transfer_mode_lookup[surface.transfer_mode]
					end
				end
			elseif p._keys.prev_weapon.pressed then
				p._light = (p._light - 1) % #Lights
			elseif p._keys.next_weapon.pressed then
				p._light = (p._light + 1) % #Lights
			end
		end

		if clear_surface then p._saved_surface.surface = nil end
	end,

	handle_teleport = function(p)
		if p._saved_facing.just_set then
			p._saved_facing.direction = p.direction
			p._saved_facing.elevation = p.elevation
			p._saved_facing.just_set = false
		end
		if (p._saved_facing.direction ~= p.direction) or
		   (p._saved_facing.elevation ~= p.elevation) or
		   (p._saved_facing.x ~= p.x) or
		   (p._saved_facing.y ~= p.y) or
		   (p._saved_facing.z ~= p.z) then
			p._saved_facing.direction = p.direction
			p._saved_facing.elevation = p.elevation
			p._saved_facing.x = p.x
			p._saved_facing.y = p.y
			p._saved_facing.z = p.z
			local o, x, y, z, poly = VML.find_target(p, false, false)
			if poly then
				p._target_poly = poly.index
				UTeleport.highlight(p, poly)
			end

			SMode.annotate(p)
		end

		if p._keys.mic.down then
			if p._keys.next_weapon.held then
				SFreeze.unfreeze(p)
				p:accelerate(0, 0, 0.05)
			elseif p._keys.prev_weapon.pressed then
				SFreeze.toggle_freeze(p)
			end
		end

		if (not p._keys.mic.down) and p._keys.primary.released then
			local poly = Polygons[p._target_poly]
			p:position(poly.x, poly.y, poly.z, poly)
			p.monster:play_sound("teleport in")
			UTeleport.remove_highlight(p)
			SFreeze.unfreeze(p)
			return
		end

		if ((not p._keys.mic.down) and (p._keys.prev_weapon.held or p._keys.next_weapon.held)) or (p._keys.mic.down and (p._keys.primary.held or p._keys.secondary.held)) then
			local diff = 1
			if p._keys.prev_weapon.held and (not p._keys.mic.down) then
				diff = -1
			elseif p._keys.primary.held and p._keys.mic.down then
				if p._keys.primary.repeated then
					diff = 1 + FFW_TELEPORT_SCRUB_SPEED
				else
					diff = 1
				end
			elseif p._keys.secondary.held and p._keys.mic.down then
				if p._keys.secondary.repeated then
					diff = -1 - FFW_TELEPORT_SCRUB_SPEED
				else
					diff = -1
				end
			end
			p._target_poly = (p._target_poly + diff) % #Polygons
			SMode.annotate(p)

			local poly = Polygons[p._target_poly]
			UTeleport.highlight(p, poly)
			local xdist = poly.x - p.x
			local ydist = poly.y - p.y
			local zdist = poly.z - (p.z + 614/1024)
			local tdist = math.sqrt(xdist*xdist + ydist*ydist + zdist*zdist)

			local el = math.asin(zdist/tdist)
			local dir = math.atan2(ydist, xdist)
			p.direction = math.deg(dir)
			p.elevation = math.deg(el)
			p._saved_facing.just_set = true
		end
	end,

	annotate = function(p)
		local poly = Polygons[p._target_poly]
	-- 	p._annotation.polygon = poly
	-- 	p._annotation.text = poly.index
	-- 	p._annotation.x = poly.x
	-- 	p._annotation.y = poly.y
	end,

	handle_choose = function(p)
		-- cycle textures
		if (p._keys.mic.down and (p._keys.primary.held or p._keys.secondary.held)) or ((not p._keys.mic.down) and (p._keys.prev_weapon.held or p._keys.next_weapon.held)) then
			local diff = 1
			if p._keys.prev_weapon.held then
				diff = -1
			elseif p._keys.mic.down and p._keys.primary.repeated then
				diff = 1 + FFW_TEXTURE_SCRUB_SPEED
			elseif p._keys.mic.down and p._keys.secondary.repeated then
				diff = 0 - (1 + FFW_TEXTURE_SCRUB_SPEED)
			elseif p._keys.mic.down and p._keys.secondary.held then
				diff = -1
			end
			local cur = p._collections.current_collection
			if cur == 0 then
				local bct = 0
				local tex = 0
				for _, collection in danger_pairs(SCollections.landscape_collections) do
					if collection == p._collections.current_landscape_collection then
						local info = SCollections.collection_map[collection]
						tex = info.offset + p._collections.current_textures[collection]
					end
					bct = bct + Collections[collection].bitmap_count
				end

				tex = (tex + diff) % bct
				for _, collection in danger_pairs(SCollections.landscape_collections) do
					local info = SCollections.collection_map[collection]
					if tex >= info.offset and tex < (info.offset + info.count) then
						local ct = tex - info.offset
						SCollections.set(p, collection, ct)
						break
					end
				end
			else
				local tex = p._collections.current_textures[cur]
				local bct = Collections[cur].bitmap_count
				local ct = (tex + diff) % bct
				SCollections.set(p, cur, ct)
			end
		end

		if p._keys.mic.down and (p._keys.next_weapon.held or p._keys.prev_weapon.held) then
			-- cycle collections
			local diff = 1
			if p._keys.prev_weapon.held then diff = -1 end

			local cur = p._collections.current_collection
			local ci = 0
			for i, c in ipairs(SCollections.wall_collections) do
				if cur == c then
					ci = i
					break
				end
			end
			ci = (ci + diff) % (#SCollections.wall_collections + 1)
			if ci == 0 then
				p._collections.current_collection = 0
			else
				p._collections.current_collection = SCollections.wall_collections[ci]
			end
		end

		-- handle menu
		if (not p._keys.mic.down) and p._keys.primary.released then
			local name = SMenu.selection(p)
			if name == nil then return end

			if string.sub(name, 1, 7) == "choose_" then
				local cc, ct = string.match(name, "(%d+)_(%d+)")
				cc = cc + 0
				ct = ct + 0
				p._collections.current_collection = cc
				p._collections.current_textures[cc] = ct
				for _, coll in danger_pairs(SCollections.landscape_collections) do
					if coll == cc then
						p._collections.current_collection = 0
						p._collections.current_landscape_collection = cc
						break
					end
				end
			elseif string.sub(name, 1, 5) == "coll_" then
				local mode = tonumber(string.sub(name, 6))
				p._collections.current_collection = mode
			end
		end
	end,

	start_attribute = function(p)
		p._apply_saved = {
			light = p._apply.light,
			texture = p._apply.texture,
			transfer = p._apply.transfer,
			align = p._apply.align,
			realign = p._apply.realign,
			transparent = p._apply.transparent,
			edit_panels = p._apply.edit_panels,
			quantize_mode = p._apply.quantize_mode,
			advanced_mode = p._advanced_mode,
			quantize = p._quantize,
			quantize_x = p._quantize_x,
			quantize_y = p._quantize_y,
			transfer_mode = p._transfer_mode,
			cur_light = p._light,
		}
	end,

	revert_attribute = function(p)
		p._apply.light = p._apply_saved.light
		p._apply.texture = p._apply_saved.texture
		p._apply.transfer = p._apply_saved.transfer
		p._apply.align = p._apply_saved.align
		p._apply.realign = p._apply_saved.realign
		p._apply.transparent = p._apply_saved.transparent
		p._apply.edit_panels = p._apply_saved.edit_panels
		p._apply.quantize_mode = p._apply_saved.quantize_mode
		p._advanced_mode = p._apply_saved.advanced_mode
		p._quantize = p._apply_saved.quantize
		p._quantize_x = p._apply_saved.quantize_x
		p._quantize_y = p._apply_saved.quantize_y
		p._transfer_mode = p._apply_saved.transfer_mode
		p._light = p._apply_saved.cur_light
	end,

	default_attribute = function(p)
		p._apply = {
			texture = APPLY_TEXTURES,
			light = APPLY_LIGHTS,
			transfer = APPLY_TRANSFER,
			align = ALIGN_ADJACENT,
			realign = REALIGN_WHEN_RETEXTURING,
			transparent = APPLY_TRANSPARENT,
			edit_panels = EDIT_PANELS,
			quantize_mode = QUANTIZE_MODE,
		}
		p._advanced_mode = false
		p._quantize = DEFAULT_QUANTIZE
		p._quantize_x = QUANTIZE_X
		p._quantize_y = QUANTIZE_Y
		p._transfer_mode = 0
		p._light = 0
	end,

	handle_attribute = function(p)
		if p._keys.mic.down then
			if p._keys.prev_weapon.pressed then
				p._apply.align = not p._apply.align
			end
			if p._keys.next_weapon.pressed then
				p._apply.transparent = not p._apply.transparent
			end
			if p._keys.primary.released then
				SMode.default_attribute(p)
			end
			if p._keys.secondary.released then
				SMode.revert_attribute(p)
			end
		else
			if p._keys.prev_weapon.pressed then
				p._light = (p._light - 1) % #Lights
			elseif p._keys.next_weapon.pressed then
				p._light = (p._light + 1) % #Lights
			end
		end

		-- handle menu
		if (not p._keys.mic.down) and p._keys.primary.released then
			local name = SMenu.selection(p)
			if name == nil then return end

			if name == "apply_tex" then
				p._apply.texture = not p._apply.texture
			elseif name == "apply_light" then
				p._apply.light = not p._apply.light
			elseif name == "apply_align" then
				p._apply.align = not p._apply.align
			elseif name == "apply_xparent" then
				p._apply.transparent = not p._apply.transparent
			elseif name == "apply_edit" then
				p._apply.edit_panels = not p._apply.edit_panels
			elseif name == "apply_transfer" then
				p._apply.transfer = not p._apply.transfer
			elseif name == "apply_realign" then
				p._apply.realign = not p._apply.realign
			elseif name == "xgrid" then
				p._quantize_x = not p._quantize_x
			elseif name == "ygrid" then
				p._quantize_y = not p._quantize_y
			elseif name == "grid_negative" then
				p._apply.quantize_mode = 1
			elseif name == "grid_positive" then
				p._apply.quantize_mode = 2
			elseif name == "grid_relative" then
				p._apply.quantize_mode = 3
			elseif name == "advanced" then
				p._advanced_mode = not p._advanced_mode
			elseif string.sub(name, 1, 5) == "snap_" then
				local mode = tonumber(string.sub(name, 6))
				p._quantize = mode
			elseif string.sub(name, 1, 9) == "transfer_" then
				if p._apply.texture or p._apply.transfer then
					local mode = tonumber(string.sub(name, 10))
					p._transfer_mode = mode
				end
			elseif string.sub(name, 1, 6) == "light_" then
				local mode = tonumber(string.sub(name, 7))
				p._light = mode
			end
		end
	end,

	handle_panel = function(p)
		if not p._keys.mic.down then
			if p._keys.prev_weapon.pressed then
				SPanel.cycle_permutation(p, -1)
			end
			if p._keys.next_weapon.pressed then
				SPanel.cycle_permutation(p, 1)
			end
		else
			if p._keys.secondary.released then
				SPanel.revert(p)
			end
			if p._keys.prev_weapon.pressed then
				SPanel.cycle_class(p, -1)
			end
			if p._keys.next_weapon.pressed then
				SPanel.cycle_class(p, 1)
			end
		end

		-- handle menu
		if (not p._keys.mic.down) and p._keys.primary.released then
			local name = SMenu.selection(p)
			if name == nil then return end

			if name == "panel_light" then
				p._panel.light_dependent = not p._panel.light_dependent
			elseif name == "panel_weapon" then
				p._panel.only_toggled_by_weapons = not p._panel.only_toggled_by_weapons
			elseif name == "panel_repair" then
				p._panel.repair = not p._panel.repair
			elseif name == "panel_active" then
				p._panel.status = not p._panel.status
			elseif string.sub(name, 1, 6) == "ptype_" then
				local mode = tonumber(string.sub(name, 7))
				if mode == 0 or p._panel.dinfo[mode] ~= nil then
					p._panel.classnum = mode
				end
			elseif string.sub(name, 1, 6) == "pperm_" then
				local mode = tonumber(string.sub(name, 7))
				p._panel.permutation = mode
			end
		end
	end,
}

SKeys = {
	init = function()
		for p in Players() do
			p._keys = { action = {}, prev_weapon = {}, next_weapon = {}, map = {}, primary = {}, secondary = {}, mic = {}, }

			for _, k in danger_pairs(p._keys) do
				k.down = false
				k.pressed = false
				k.released = false
				k.first = -5
				k.lag = -5
				k.highlight = false
				k.held = false
			end

			p._overhead = false
			p._terminal = false

			if p.local_ then
				p.texture_palette.slots[39].texture_index = 0
			end
		end
	end,

	track_key = function(p, flag, key, disable)
		local k = p._keys[key]
		local ticks = Game.ticks

		if p.action_flags[flag] then
			if disable then
				p.action_flags[flag] = false
			end

			if k.down then
				k.pressed = false
			else
				k.down = true
				k.pressed = true
				k.released = false
				k.first = ticks
				k.lag = ticks
			end
		else
			if k.down then
				k.down = false
				k.pressed = false
				k.released = true
			else
				k.released = false
			end
		end

		k.highlight = false
		k.held = false
		k.repeated = false
		local passed = ticks - k.first

		if k.down then
			k.highlight = true
			if passed == 0 then
				k.held = true
			elseif passed >= FFW_INITIAL_DELAY then
				if ((passed - FFW_INITIAL_DELAY) % (FFW_REPEAT_DELAY + 1)) == 0 then
					k.held = true
					k.repeated = true
				end
			end
		elseif passed < (KEY_HIGHLIGHT_DELAY + 1) then
			k.highlight = true
		end
	end,

	cancel_highlight = function(k)
		if not k.down then
			k.lag = -5
			k.highlight = false
		end
	end,

	update = function()
		local ticks = Game.ticks
		for p in Players() do
			if not p._terminal then

				-- track keys
				SKeys.track_key(p, 'cycle_weapons_backward', 'prev_weapon', true)
				SKeys.track_key(p, 'cycle_weapons_forward', 'next_weapon', true)
				SKeys.track_key(p, 'left_trigger', 'primary', true)
				SKeys.track_key(p, 'right_trigger', 'secondary', true)
				SKeys.track_key(p, 'microphone_button', 'mic', true)

				SKeys.track_key(p, 'action_trigger', 'action', p._keys.mic.down)
				SKeys.track_key(p, 'toggle_map', 'map', p._keys.mic.down)

				if p.action_flags.toggle_map then
					p._overhead = not p._overhead
				end

				-- cancel display highlights if we see a new key
				if p._keys.action.pressed or p._keys.next_weapon.pressed or p._keys.prev_weapon.pressed or p._keys.map.pressed then
					SKeys.cancel_highlight(p._keys.action)
					SKeys.cancel_highlight(p._keys.prev_weapon)
					SKeys.cancel_highlight(p._keys.next_weapon)
					SKeys.cancel_highlight(p._keys.map)
				end

				if p.local_ then
					local down = 0
					if p._keys.primary.highlight then down = down + 1 end
					if p._keys.secondary.highlight then down = down + 2 end
					if p._keys.mic.highlight then down = down + 4 end

					if p._keys.prev_weapon.highlight then down = down + 8 end
					if p._keys.next_weapon.highlight then down = down + 16 end
					if p._keys.action.highlight then down = down + 32 end
					if p._keys.map.highlight then down = down + 64 end

					p.texture_palette.slots[39].texture_index = down

					local dummy = 0
					if p._mic_dummy then dummy = dummy + 4 end

					p.texture_palette.slots[42].texture_index = dummy
				end
			end
		end
	end,
}

SFreeze = {
	ranges = {
		menu = {
			xsize = 600, ysize = 320,
			xoff = 20, yoff = 80,
			xrange = MENU_HORIZONTAL_RANGE, yrange = MENU_VERTICAL_RANGE
		},
		drag = {
			xsize = 2048*DRAG_HORIZONTAL_LIMIT, ysize = 2048*DRAG_VERTICAL_LIMIT,
			xoff = -1024*DRAG_HORIZONTAL_LIMIT, yoff = -1024*DRAG_VERTICAL_LIMIT,
			xrange = DRAG_HORIZONTAL_RANGE, yrange = DRAG_VERTICAL_RANGE
		},
	},

	init = function()
		for _,rr in danger_pairs(SFreeze.ranges) do
			rr.xscale = rr.xsize / (rr.xrange * 2)
			rr.yscale = rr.ysize / (rr.yrange * 2)
		end
		for p in Players() do
			p._freeze = {
				frozen = false,
				mode = nil,
				point = { x = 0, y = 0, z = 0, poly = 0, direction = 0, elevation = 0, },
				restore = { direction = 0, elevation = 0, }
			}
		end
	end,

	postidle = function()
		for p in Players() do
			if p._freeze.mode then
				p._freeze.restore.direction = p.direction
				p._freeze.restore.elevation = p.elevation
				p.direction = p._freeze.point.direction
				p.elevation = p._freeze.point.elevation
			end
			if p._freeze.frozen or p._freeze.mode then
				SFreeze.reposition(p)
			end
		end
	end,

	reposition = function(p)
		local z = p._freeze.point.z
		if p._freeze.mode == "menu" then z = p.polygon.z end
		p:position(p._freeze.point.x, p._freeze.point.y, z, p._freeze.point.poly)
		p.external_velocity.i = 0
		p.external_velocity.j = 0
		p.external_velocity.k = 0
	end,

	freeze = function(p)
		if p._freeze.frozen then return end
		p._freeze.frozen = true
		if not p._freeze.mode then
			p._freeze.point.x = p.x
			p._freeze.point.y = p.y
			p._freeze.point.z = math.max(p.z, p.polygon.z + 1/1024.0)
			p._freeze.point.poly = p.polygon
			SFreeze.reposition(p)
		end
	end,

	unfreeze = function(p)
		p._freeze.frozen = false
	end,

	toggle_freeze = function(p)
		if p._freeze.frozen then
			SFreeze.unfreeze(p)
		else
			SFreeze.freeze(p)
		end
	end,

	frozen = function(p)
		return p._freeze.frozen
	end,

	enter_mode = function(p, mode)
		local old_mode = p._freeze.mode
		if old_mode == mode then return end
		if old_mode then
			p.direction = p._freeze.point.direction
			p.elevation = p._freeze.point.elevation
		end
		if mode then
			if not p._freeze.frozen then
				p._freeze.point.x = p.x
				p._freeze.point.y = p.y
				p._freeze.point.z = math.max(p.z, p.polygon.z + 1/1024.0)
				p._freeze.point.poly = p.polygon
				SFreeze.reposition(p)
			end
			p._freeze.point.direction = p.direction
			p._freeze.point.elevation = p.elevation
			p._freeze.extra_dir = 0
			p._freeze.extra_elev = 0
			p._freeze.last_forward = p.internal_velocity.forward
			p._freeze.last_perpendicular = p.internal_velocity.perpendicular
			p._freeze.last_motion = {}
			p._freeze.last_motion["forward"] = 0
			p._freeze.last_motion["perpendicular"] = 0
			p.direction = 180
			p.elevation = 0
		end
		p._freeze.mode = mode
	end,

	in_mode = function(p, mode)
		return p._freeze.mode == mode
	end,

	detect_motion = function(p, which)
		if not p._freeze.mode then return 0 end

		local last = p._freeze["last_" .. which]
		if last == nil then last = 0 end
		local cur = p.internal_velocity[which]
		p._freeze["last_" .. which] = cur

		local exp = 0
		if last < 0 then
			exp = math.min(0, last + 0.02)
		elseif last > 0 then
			exp = math.max(0, last - 0.02)
		end

		local res = tonumber(string.format("%.4f", cur - exp))
		if (cur - exp) < -0.001 then
			return -1
		elseif (cur + exp) > 0.001 then
			return 1
		end
		return 0
	end,

	update = function()
		for p in Players() do
			if p._freeze.frozen or p._freeze.mode then
				SFreeze.reposition(p)
			end
			if p._freeze.mode then
				p.direction = p._freeze.restore.direction
				p.elevation = p._freeze.restore.elevation
				local check_direction = true

				if p._freeze.mode == "menu" then
					-- check for movement keys
					local last_mov = {}
					local cur_mov = {}
					local any_move = false
					for _,dir in danger_pairs({ "forward", "perpendicular" }) do
						last_mov[dir] = p._freeze.last_motion[dir]
						cur_mov[dir] = SFreeze.detect_motion(p, dir)
						p._freeze.last_motion[dir] = cur_mov[dir]
						if cur_mov[dir] ~= 0 and cur_mov[dir] ~= last_mov[dir] then
							any_move = true
						end
					end
					if any_move then
						-- position cursor to closest menu item
						local item
						if cur_mov["forward"] == 1 then
							item = SMenu.find_next(p, "up")
						elseif cur_mov["forward"] == -1 then
							item = SMenu.find_next(p, "down")
						elseif cur_mov["perpendicular"] == 1 then
							item = SMenu.find_next(p, "right")
						elseif cur_mov["perpendicular"] == -1 then
							item = SMenu.find_next(p, "left")
						end
						if item then
							SFreeze.set_coord(p, item[3] + item[5]/2,
												item[4] + item[6]/2)
						end
					end
				end

				local nd = p.direction - 180
				local ne = 0 - p.elevation

				if (nd < -90) or (nd > 90) then
					p._freeze.extra_dir = p._freeze.extra_dir + nd
					p.direction = 180
					nd = 0
				end
				if (ne < -20) or (ne > 20) then
					p._freeze.extra_elev = p._freeze.extra_elev + ne
					p.elevation = 0
					ne = 0
				end

				local rr = SFreeze.ranges[p._freeze.mode]
				if (p._freeze.extra_dir + nd) > rr.xrange then
					p._freeze.extra_dir = rr.xrange - nd
				elseif (p._freeze.extra_dir + nd) < -rr.xrange then
					p._freeze.extra_dir = -rr.xrange - nd
				end
				if (p._freeze.extra_elev + ne) > rr.yrange then
					p._freeze.extra_elev = rr.yrange - ne
				elseif (p._freeze.extra_elev + ne) < -rr.yrange then
					p._freeze.extra_elev = -rr.yrange - ne
				end
			end
		end
	end,

	coord = function(p)
		local rr = SFreeze.ranges[p._freeze.mode]

		local xa = p.direction - 180 + p._freeze.extra_dir + rr.xrange
		local ya = 0 - p.elevation + p._freeze.extra_elev + rr.yrange

		return math.floor(rr.xoff + xa*rr.xscale), math.floor(rr.yoff + ya*rr.yscale)
	end,

	set_coord = function(p, x, y)
		local rr = SFreeze.ranges[p._freeze.mode]
		local xa = (x - rr.xoff)/rr.xscale
		local ya = (y - rr.yoff)/rr.yscale

		p.direction = 180
		p.elevation = 0
		p._freeze.extra_dir = xa - rr.xrange
		p._freeze.extra_elev = ya - rr.yrange
	end,

	orig_dir = function(p)
		if not p._freeze.mode then return p.direction end
		return p._freeze.point.direction
	end,
}

SPanel = {
	oxygen = 1,
	x1 = 2,
	x2 = 3,
	x3 = 4,
	light_switch = 5,
	platform_switch = 6,
	tag_switch = 7,
	save = 8,
	terminal = 9,
	chip = 10,
	wires = 11,
	classorder = { 5, 6, 7, 10, 11, 1, 2, 3, 4, 8, 9, 0 },
	device_collections = {},
	
	init = function()
		-- these must be hard-coded into Forge; the engine can't tell them apart
		ControlPanelTypes[3]._type = SPanel.chip
		ControlPanelTypes[9]._type = SPanel.wires
		ControlPanelTypes[19]._type = SPanel.chip
		ControlPanelTypes[20]._type = SPanel.wires
		ControlPanelTypes[30]._type = SPanel.chip
		ControlPanelTypes[31]._type = SPanel.wires
		ControlPanelTypes[41]._type = SPanel.chip
		ControlPanelTypes[42]._type = SPanel.wires
		ControlPanelTypes[52]._type = SPanel.chip
		ControlPanelTypes[53]._type = SPanel.wires

		for t in ControlPanelTypes() do
			if t.collection then
				if not SPanel.device_collections[t.collection.index] then
					SPanel.device_collections[t.collection.index] = {}
				end
				local cc = SPanel.device_collections[t.collection.index]

				local ttype = SPanel.classnum_from_type(t)

				for _,v in ipairs({ t.active_texture_index, t.inactive_texture_index }) do
					if not cc[v] then cc[v] = {} end
					if not cc[v][ttype] then
						cc[v][ttype] = t
					end
				end
			end
		end
	end,

	update = function()
		for p in Players() do
			if p.local_ then
				if p._panel.editing then

					local classfield = 0
					for i = 0,10 do
						if p._panel.dinfo[i + 1] ~= nil then
							classfield = classfield + 2^i
						end
					end
					p.texture_palette.slots[48].texture_index = classfield % 128
					p.texture_palette.slots[49].texture_index = math.floor(classfield/128)

					p.texture_palette.slots[50].texture_index = p._panel.classnum

					local option = 0
					if p._panel.light_dependent then option = option + 1 end
					if p._panel.only_toggled_by_weapons then option = option + 2 end
					if p._panel.repair then option = option + 4 end
					if p._panel.status then option = option + 8 end
					p.texture_palette.slots[51].texture_index = option

					local perm = p._panel.permutation
					if perm < 0 or perm > 32767 then perm = 0 end
					p.texture_palette.slots[52].texture_index = perm % 128
					p.texture_palette.slots[53].texture_index = math.floor(perm/128)
				else
					p.texture_palette.slots[48].texture_index = 0
					p.texture_palette.slots[49].texture_index = 0
					p.texture_palette.slots[50].texture_index = 0
					p.texture_palette.slots[51].texture_index = 0
					p.texture_palette.slots[52].texture_index = 0
					p.texture_palette.slots[53].texture_index = 0
				end
			end
		end
	end,

	cycle_class = function(p, dir)
		local cur = p._panel.classnum
		local dinfo = p._panel.dinfo
		local total = #SPanel.classorder

		local idx = total
		if dir < 0 then idx = 1 end
		for i,v in ipairs(SPanel.classorder) do
			if cur == v then
				idx = i
				break
			end
		end

		repeat
			idx = (((idx + dir) - 1) % total) + 1
		until (SPanel.classorder[idx] == 0) or dinfo[SPanel.classorder[idx]]

		p._panel.classnum = SPanel.classorder[idx]
	end,

	cycle_permutation = function(p, dir)
		local cur = p._panel.classnum
		local perm = p._panel.permutation

		if cur == SPanel.platform_switch then
			local total = #SPlatforms.sorted_platforms
			if total > 0 then
				local idx = SPlatforms.index_lookup[perm]
				if idx == nil then 
					idx = total
					if dir < 0 then idx = 1 end
				end
				idx = (((idx + dir) - 1) % total) + 1
				p._panel.permutation = SPlatforms.sorted_platforms[idx].polygon.index
			end
		else
			local total = 0
			if cur == SPanel.light_switch then
				total = #Lights
			elseif cur == SPanel.terminal then
				total = #Terminals
				if total < 1 then total = MAX_SCRIPTS end
			elseif cur == SPanel.tag_switch or cur == SPanel.chip or cur == SPanel.wires then
				total = MAX_TAGS
			end
			if total > 0 then
				if perm < 0 or perm >= total then
					perm = total - 1
					if dir < 0 then perm = 0 end
				end
				p._panel.permutation = (perm + dir) % total
			end
		end
	end,

	menu_name = function(p)
		local current_class = 0
		if p._panel and (p._panel.classnum ~= nil) then
			current_class = p._panel.classnum
		end

		if current_class == SPanel.oxygen or current_class == SPanel.x1 or current_class == SPanel.x2 or current_class == SPanel.x3 or current_class == SPanel.save then
			return "panel_plain"
		elseif current_class == SPanel.terminal then
			return "panel_terminal"
		elseif current_class == SPanel.light_switch then
			return "panel_light"
		elseif current_class == SPanel.platform_switch then
			return "panel_platform"
		elseif current_class == SPanel.tag_switch or current_class == SPanel.chip or current_class == SPanel.wires then
			return "panel_tag"
		end
		return "panel_off"
	end,

	surface_can_hold_panel = function(surface)
		if not is_primary_side(surface) then return false end
		local cc = surface.collection.index
		local ct = surface.texture_index
		if SPanel.device_collections[cc] and SPanel.device_collections[cc][ct] then return true end
		return false
	end,

	surface_has_valid_panel = function(surface)
		if not is_primary_side(surface) then return false end
		local cp = Sides[surface.index].control_panel
		if not cp then return false end
		if surface.collection ~= cp.type.collection then return false end
		if surface.texture_index ~= cp.type.active_texture_index and surface.texture_index ~= cp.type.inactive_texture_index then return false end
		return true
	end,

	classnum_from_type = function(ctype)
		local idx = ctype.class.index + 1
		if ctype._type then idx = ctype._type end
		return idx
	end,

	add_for_editing = function(p, surface)
		p._panel.sides[surface.index] = true
	end,

	start_editing = function(p, surface)
		p._panel.editing = true
		p._panel.classnum = 0
		p._panel.permutation = 0
		p._panel.light_dependent = false
		p._panel.only_toggled_by_weapons = false
		p._panel.repair = false
		p._panel.status = false
		p._panel.surface = surface
		p._panel.sides = {}
		p._panel.sides[surface.index] = true
		p._panel.dinfo = SPanel.device_collections[surface.collection.index][surface.texture_index]

		if SPanel.surface_has_valid_panel(surface) then
			-- populate info from existing panel
			local cp = Sides[surface.index].control_panel
			p._panel.classnum = SPanel.classnum_from_type(cp.type)
			p._panel.light_dependent = cp.light_dependent
			p._panel.only_toggled_by_weapons = cp.only_toggled_by_weapons
			p._panel.repair = cp.repair
			p._panel.status = cp.status
			p._panel.permutation = cp.permutation
		else
			-- find first valid type
			local dinfo = p._panel.dinfo
			for classnum = 1,11 do
				if dinfo[classnum] ~= nil then
					p._panel.classnum = classnum
					if ct == dinfo[classnum].active_texture_index then
						p._panel.status = true
					end
					break
				end
			end
		end

		p._panel_saved = {
			classnum = p._panel.classnum,
			permutation = p._panel.permutation,
			light_dependent = p._panel.light_dependent,
			only_toggled_by_weapons = p._panel.only_toggled_by_weapons,
			repair = p._panel.repair,
			status = p._panel.status,
		}
	end,

	revert = function(p)
		p._panel.classnum = p._panel_saved.classnum
		p._panel.permutation = p._panel_saved.permutation
		p._panel.light_dependent = p._panel_saved.light_dependent
		p._panel.only_toggled_by_weapons = p._panel_saved.only_toggled_by_weapons
		p._panel.repair = p._panel_saved.repair
		p._panel.status = p._panel_saved.status
	end,

	stop_editing = function(p)
		if p._panel.editing then
			if p._panel.classnum == 0 then
				for sidx,_ in danger_pairs(p._panel.sides) do
					Sides[sidx].control_panel = false
				end
			else
				local class = p._panel.classnum
				local ctype = p._panel.dinfo[p._panel.classnum]
				p._panel.device = ctype

				for sidx,_ in danger_pairs(p._panel.sides) do
					VML.save_control_panel(Sides[sidx], p._panel)
				end
			end
			p._panel.editing = false
		end
	end,
}

SStatus = {
	init = function()
		for p in Players() do
			if p.local_ then
				p.texture_palette.slots[41].texture_index = 0
				p.texture_palette.slots[43].texture_index = 0
				p.texture_palette.slots[44].texture_index = 0
				p.texture_palette.slots[44].type = 2
				p.texture_palette.slots[45].texture_index = 0
				p.texture_palette.slots[45].type = QUANTIZE_MODE
				p.texture_palette.slots[46].texture_index = 0
				p.texture_palette.slots[47].texture_index = 0
				p.texture_palette.slots[54].texture_index = 0
				p.texture_palette.slots[55].texture_index = 0
				p.texture_palette.slots[56].texture_index = 0
				p.texture_palette.slots[57].texture_index = 0
			end
		end
	end,

	update = function()
		for p in Players() do
			if p.local_ then
				local status = 0
				if SFreeze.frozen(p) then status = status + 1 end
				if SUndo.undo_active(p) then status = status + 2 end
				if SUndo.redo_active(p) then status = status + 4 end
				if (p._mode == SMode.apply or p._mode == SMode.teleport) and (not SFreeze.in_mode(p, "drag")) and p:find_action_key_target() then status = status + 8 end
				if p._advanced_mode then status = status + 16 end
				p.texture_palette.slots[41].texture_index = status

				-- transfer mode
				p.texture_palette.slots[43].texture_index = p._light
				if p._collections.current_collection == 0 then
					p.texture_palette.slots[44].texture_index = 5
				else
					p.texture_palette.slots[44].texture_index = p._transfer_mode
					if p._apply.transfer then
						p.texture_palette.slots[44].type = 2
					else
						p.texture_palette.slots[44].type = 1
					end
				end

				-- some of the grid stuff
				p.texture_palette.slots[45].texture_index = p._quantize
				-- p.texture_palette.slots[45].collection = status
				p.texture_palette.slots[45].type = p._apply.quantize_mode

				status = 0
				if p._apply.texture then status = status + 1 end
				if p._apply.light then status = status + 2 end
				if p._apply.align then status = status + 4 end
				if p._apply.transparent then status = status + 8 end
				if p._apply.edit_panels then status = status + 16 end
				if p._apply.realign then status = status + 32 end
				-- i dunno why but i have to do this here
				if p._quantize_x then status = status + 64 end
				if p._quantize_y then status = status + 128 end
				p.texture_palette.slots[46].texture_index = status

				p.texture_palette.slots[47].texture_index = p._menu_item

				p.texture_palette.slots[54].texture_index = p._cursor_x % 128
				p.texture_palette.slots[55].texture_index = math.floor(p._cursor_x / 128)
				p.texture_palette.slots[56].texture_index = p._cursor_y % 128
				p.texture_palette.slots[57].texture_index = math.floor(p._cursor_y / 128)
			end
		end
	end,
}


SMenu = {
	menus = {
		[SMode.attribute] = {
			{ "bg", nil, 20, 80, 600, 320, nil },
			{ "checkbox", "apply_tex", 30, 85, 160, 20, "Apply texture" },
			{ "checkbox", "apply_align", 30, 105, 160, 20, "Align adjacent" },
			{ "checkbox", "apply_edit", 30, 125, 160, 20, "Edit switches and panels" },
			{ "checkbox", "apply_xparent", 30, 145, 160, 20, "Edit transparent sides" },
			{ "checkbox", "apply_realign", 30, 165, 160, 20, "Realign when retexturing" },
			{ "checkbox", "advanced", 30, 185, 160, 20, "Visual Mode header" },
			{ "label", "nil", 30+5, 210, 45, 20, "Snap:" },
			{ "checkbox", "xgrid", 30, 230, 45, 20, "X" },
			{ "checkbox", "ygrid", 30, 250, 45, 20, "Y" },
			{ "radio", "grid_positive", 75, 210, 115, 20, "Positive (absolute)" },
			{ "radio", "grid_relative", 75, 230, 115, 20, "Centred (relative)" },
			{ "radio", "grid_negative", 75, 250, 115, 20, "Negative (absolute)" },
			{ "radio", "snap_1", 30, 270, 80, 20, snap_modes[1] },
			{ "radio", "snap_2", 30, 290, 80, 20, snap_modes[2] },
			{ "radio", "snap_3", 30, 310, 80, 20, snap_modes[3] },
			{ "radio", "snap_4", 30, 330, 80, 20, snap_modes[4] },
			{ "radio", "snap_5", 30, 350, 80, 20, snap_modes[5] },
			{ "radio", "snap_6", 30, 370, 80, 20, snap_modes[6] },
			{ "radio", "snap_7", 110, 270, 80, 20, snap_modes[7] },
			{ "radio", "snap_8", 110, 290, 80, 20, snap_modes[8] },
			{ "radio", "snap_9", 110, 310, 80, 20, snap_modes[9] },
			{ "radio", "snap_10", 110, 330, 80, 20, snap_modes[10] },
			{ "radio", "snap_11", 110, 350, 80, 20, snap_modes[11] },
			{ "radio", "snap_12", 110, 370, 80, 20, snap_modes[12] },
			{ "checkbox", "apply_light", 205, 85, 240, 20, "Apply light:" },
			{ "checkbox", "apply_transfer", 215+5, 250, 240, 20, "Apply texture mode" },
			{ "radio", "transfer_0", 215, 270, 80, 20, "Normal" },
			{ "radio", "transfer_1", 215, 290, 80, 20, "Pulsate" },
			{ "radio", "transfer_2", 215, 310, 80, 20, "Wobble" },
			{ "radio", "transfer_6", 215, 330, 80, 20, "Horizontal" },
			{ "radio", "transfer_8", 215, 350, 80, 20, "Vertical" },
			{ "radio", "transfer_10", 215, 370, 80, 20, "Wander" },
			{ "radio", "transfer_5", 295, 270, 80, 20, "Landscape" },
			{ "radio", "transfer_4", 295, 290, 80, 20, "Static" },
			{ "radio", "transfer_3", 295, 310, 80, 20, "Fast wobble" },
			{ "radio", "transfer_7", 295, 330, 80, 20, "Fast horiz." },
			{ "radio", "transfer_9", 295, 350, 80, 20, "Fast vert." },
			{ "radio", "transfer_11", 295, 370, 80, 20, "Fast wander" },
			{ "radio", "transfer_12", 375, 270, 80, 20, "Rev. horiz." },
			{ "radio", "transfer_13", 375, 290, 80, 20, "Rev. fast horiz." },
			{ "radio", "transfer_14", 375, 310, 80, 20, "Rev. vert." },
			{ "radio", "transfer_15", 375, 330, 80, 20, "Rev. fast vert." },
			{ "radio", "transfer_16", 375, 350, 80, 20, "2x" },
			{ "radio", "transfer_17", 375, 370, 80, 20, "4x" },
			{ "label", nil, 485, 250, 120, 20, "Texture preview" },
			{ "applypreview", nil, 485, 270, 120, 1, nil },
		},
		panel_off = {
			{ "tab_bg", nil, 150, 80, 470, 320, nil },
			{ "tab", "ptype_5", 20, 105, 130, 20, "Light switch" },
			{ "tab", "ptype_6", 20, 125, 130, 20, "Platform switch" },
			{ "tab", "ptype_7", 20, 145, 130, 20, "Tag switch" },
			{ "tab", "ptype_10", 20, 165, 130, 20, "Chip insertion" },
			{ "tab", "ptype_11", 20, 185, 130, 20, "Wires" },
			{ "tab", "ptype_1", 20, 215, 130, 20, "Oxygen" },
			{ "tab", "ptype_2", 20, 235, 130, 20, "1X health" },
			{ "tab", "ptype_3", 20, 255, 130, 20, "2X health" },
			{ "tab", "ptype_4", 20, 275, 130, 20, "3X health" },
			{ "tab", "ptype_8", 20, 305, 130, 20, "Pattern buffer" },
			{ "tab", "ptype_9", 20, 325, 130, 20, "Terminal" },
			{ "tab", "ptype_0", 20, 355, 130, 20, "Inactive" },
		},
		panel_plain = {
			{ "tab_bg", nil, 150, 80, 470, 320, nil },
			{ "tab", "ptype_5", 20, 105, 130, 20, "Light switch" },
			{ "tab", "ptype_6", 20, 125, 130, 20, "Platform switch" },
			{ "tab", "ptype_7", 20, 145, 130, 20, "Tag switch" },
			{ "tab", "ptype_10", 20, 165, 130, 20, "Chip insertion" },
			{ "tab", "ptype_11", 20, 185, 130, 20, "Wires" },
			{ "tab", "ptype_1", 20, 215, 130, 20, "Oxygen" },
			{ "tab", "ptype_2", 20, 235, 130, 20, "1X health" },
			{ "tab", "ptype_3", 20, 255, 130, 20, "2X health" },
			{ "tab", "ptype_4", 20, 275, 130, 20, "3X health" },
			{ "tab", "ptype_8", 20, 305, 130, 20, "Pattern buffer" },
			{ "tab", "ptype_9", 20, 325, 130, 20, "Terminal" },
			{ "tab", "ptype_0", 20, 355, 130, 20, "Inactive" },
			{ "checkbox", "panel_light", 170, 90, 150-3, 20, "Light dependent" },
		},
		panel_terminal = {
			{ "tab_bg", nil, 150, 80, 470, 320, nil },
			{ "tab", "ptype_5", 20, 105, 130, 20, "Light switch" },
			{ "tab", "ptype_6", 20, 125, 130, 20, "Platform switch" },
			{ "tab", "ptype_7", 20, 145, 130, 20, "Tag switch" },
			{ "tab", "ptype_10", 20, 165, 130, 20, "Chip insertion" },
			{ "tab", "ptype_11", 20, 185, 130, 20, "Wires" },
			{ "tab", "ptype_1", 20, 215, 130, 20, "Oxygen" },
			{ "tab", "ptype_2", 20, 235, 130, 20, "1X health" },
			{ "tab", "ptype_3", 20, 255, 130, 20, "2X health" },
			{ "tab", "ptype_4", 20, 275, 130, 20, "3X health" },
			{ "tab", "ptype_8", 20, 305, 130, 20, "Pattern buffer" },
			{ "tab", "ptype_9", 20, 325, 130, 20, "Terminal" },
			{ "tab", "ptype_0", 20, 355, 130, 20, "Inactive" },
			{ "checkbox", "panel_light", 170, 90, 150-3, 20, "Light dependent" },
			{ "label", nil, 170+5, 130, 150, 20, "Terminal script" },
		},
		panel_light = {
			{ "tab_bg", nil, 150, 80, 470, 320, nil },
			{ "tab", "ptype_5", 20, 105, 130, 20, "Light switch" },
			{ "tab", "ptype_6", 20, 125, 130, 20, "Platform switch" },
			{ "tab", "ptype_7", 20, 145, 130, 20, "Tag switch" },
			{ "tab", "ptype_10", 20, 165, 130, 20, "Chip insertion" },
			{ "tab", "ptype_11", 20, 185, 130, 20, "Wires" },
			{ "tab", "ptype_1", 20, 215, 130, 20, "Oxygen" },
			{ "tab", "ptype_2", 20, 235, 130, 20, "1X health" },
			{ "tab", "ptype_3", 20, 255, 130, 20, "2X health" },
			{ "tab", "ptype_4", 20, 275, 130, 20, "3X health" },
			{ "tab", "ptype_8", 20, 305, 130, 20, "Pattern buffer" },
			{ "tab", "ptype_9", 20, 325, 130, 20, "Terminal" },
			{ "tab", "ptype_0", 20, 355, 130, 20, "Inactive" },
			{ "checkbox", "panel_light", 170, 90, 150-3, 20, "Light dependent" },
			{ "checkbox", "panel_weapon", 170, 110, 150-3, 20, "Only toggled by weapons" },
			{ "checkbox", "panel_repair", 170, 130, 150-3, 20, "Repair switch" },
			{ "label", nil, 170+5, 170, 150, 20, "Light" },
		},
		panel_platform = {
			{ "tab_bg", nil, 150, 80, 470, 320, nil },
			{ "tab", "ptype_5", 20, 105, 130, 20, "Light switch" },
			{ "tab", "ptype_6", 20, 125, 130, 20, "Platform switch" },
			{ "tab", "ptype_7", 20, 145, 130, 20, "Tag switch" },
			{ "tab", "ptype_10", 20, 165, 130, 20, "Chip insertion" },
			{ "tab", "ptype_11", 20, 185, 130, 20, "Wires" },
			{ "tab", "ptype_1", 20, 215, 130, 20, "Oxygen" },
			{ "tab", "ptype_2", 20, 235, 130, 20, "1X health" },
			{ "tab", "ptype_3", 20, 255, 130, 20, "2X health" },
			{ "tab", "ptype_4", 20, 275, 130, 20, "3X health" },
			{ "tab", "ptype_8", 20, 305, 130, 20, "Pattern buffer" },
			{ "tab", "ptype_9", 20, 325, 130, 20, "Terminal" },
			{ "tab", "ptype_0", 20, 355, 130, 20, "Inactive" },
			{ "checkbox", "panel_light", 170, 90, 150-3, 20, "Light dependent" },
			{ "checkbox", "panel_weapon", 170, 110, 150-3, 20, "Only toggled by weapons" },
			{ "checkbox", "panel_repair", 170, 130, 150-3, 20, "Repair switch" },
			{ "label", nil, 170+5, 170, 150, 20, "Platform" },
		},
		panel_tag = {
			{ "tab_bg", nil, 150, 80, 470, 320, nil },
			{ "tab", "ptype_5", 20, 105, 130, 20, "Light switch" },
			{ "tab", "ptype_6", 20, 125, 130, 20, "Platform switch" },
			{ "tab", "ptype_7", 20, 145, 130, 20, "Tag switch" },
			{ "tab", "ptype_10", 20, 165, 130, 20, "Chip insertion" },
			{ "tab", "ptype_11", 20, 185, 130, 20, "Wires" },
			{ "tab", "ptype_1", 20, 215, 130, 20, "Oxygen" },
			{ "tab", "ptype_2", 20, 235, 130, 20, "1X health" },
			{ "tab", "ptype_3", 20, 255, 130, 20, "2X health" },
			{ "tab", "ptype_4", 20, 275, 130, 20, "3X health" },
			{ "tab", "ptype_8", 20, 305, 130, 20, "Pattern buffer" },
			{ "tab", "ptype_9", 20, 325, 130, 20, "Terminal" },
			{ "tab", "ptype_0", 20, 355, 130, 20, "Inactive" },
			{ "checkbox", "panel_light", 170, 90, 150-3, 20, "Light dependent" },
			{ "checkbox", "panel_weapon", 170, 110, 150-3, 20, "Only toggled by weapons" },
			{ "checkbox", "panel_repair", 170, 130, 150-3, 20, "Repair switch" },
			{ "checkbox", "panel_active", 220-1, 170, 100-2, 20, "Tag is active" },
			{ "label", nil, 170+5, 170, 50-18, 20, "Tag" },
		}
	},

	inited = {},

	selection = function(p)
		local mode = SMode.current_menu_name(p)
		if not SMenu.inited[mode] then SMenu.init_menu(mode) end
		local m = SMenu.menus[mode]
		local x, y = SMenu.coord(p)

		for idx, item in ipairs(m) do
			if SMenu.clickable(item[1]) then
				if x >= item[3] and y >= item[4] and x <= (item[3] + item[5]) and y <= (item[4] + item[6]) then
					return item[2]
				end
			end
		end
		return nil
	end,

	find_next = function(p, direction)
		local mode = SMode.current_menu_name(p)
		if not SMenu.inited[mode] then SMenu.init_menu(mode) end
		local m = SMenu.menus[mode]
		local x, y = SMenu.coord(p)

		local closest = nil
		local distance = 999
		for idx, item in ipairs(m) do
			if SMenu.clickable(item[1]) then
				if (direction == "down" or direction == "up") and
				(x >= item[3] and x <= (item[3] + item[5])) then
					if direction == "down" and y < item[4] then
						if distance > (item[4] - y) then
							distance = item[4] - y
							closest = item
						end
					elseif direction == "up" and y > (item[4] + item[6]) then
						if distance > (y - (item[4] + item[6])) then
							distance = y - (item[4] + item[6])
							closest = item
						end
					end
				elseif (direction == "left" or direction == "right") and
					(y >= item[4] and y <= (item[4] + item[6])) then
					if direction == "right" and x < item[3] then
						if distance > (item[3] - x) then
							distance = item[3] - x
							closest = item
						end
					elseif direction == "left" and x > (item[3] + item[5]) then
						if distance > (x - (item[3] + item[5])) then
							distance = x - (item[3] + item[5])
							closest = item
						end
					end
				end
			end
		end

		if not closest then
			distance = 999
			for idx, item in ipairs(m) do
				if SMenu.clickable(item[1]) then
					if (direction == "down" and y < item[4]) or
					(direction == "up"	 and y > (item[4] + item[6])) then
						local midx = item[3] + item[5]/2
						local dist = math.abs(x - midx)
						if distance > dist then
							distance = dist
							closest = item
						end
					elseif (direction == "right" and x < item[3]) or
						(direction == "left" and x > (item[3] + item[5])) then
						local midy = item[4] + item[6]/2
						local dist = math.abs(y - midy)
						if distance > dist then
							distance = dist
							closest = item
						end
					end
				end
			end
		end

		return closest
	end,

	coord = function(p)
		return SFreeze.coord(p)
	end,

	init_menu = function(mode)
		local menu = SMenu.menus[mode]
		if mode == SMode.attribute then
			for i = 1,math.min(#Lights, MAX_LIGHTS) do
				local l = i - 1
				local yoff = (l % 7) * 20
				local xoff = math.floor(l / 7) * 30
				local w = 30
				if xoff == 0 then
					w = w - 13
				else
					xoff = xoff - 13
				end
				table.insert(menu, 13 + l,
					{ "light", "light_" .. l, 215 + xoff, 105 + yoff, w, 20, tostring(l) })
			end
		elseif mode == "panel_light" then
			for i = 1,math.min(#Lights, MAX_LIGHTS) do
				local l = i - 1
				local yoff = (l % 7) * 20
				local xoff = math.floor(l / 7) * 30
				local w = 30
				if xoff == 0 then
					w = w - 13
				else
					xoff = xoff - 13
				end
				table.insert(menu,
					{ "light", "pperm_" .. l, 170 + xoff, 190 + yoff, w, 20, tostring(l) })
			end
		elseif mode == "panel_terminal" then
			local num_scripts = #Terminals
			if num_scripts < 1 then num_scripts = MAX_SCRIPTS end
			for i = 1,math.min(num_scripts, 90) do
				local l = i - 1
				local yoff = (l % 10) * 20
				local xoff = math.floor(l / 10) * 49
				table.insert(menu,
					{ "radio", "pperm_" .. l, 170 + xoff, 150 + yoff, 49, 20, tostring(l) })
			end
		elseif mode == "panel_tag" then
			for i = 1,math.min(MAX_TAGS, 90) do
				local l = i - 1
				local yoff = (l % 10) * 20
				local xoff = math.floor(l / 10) * 49
				table.insert(menu,
					{ "radio", "pperm_" .. l, 170 + xoff, 190 + yoff, 49, 20, tostring(l) })
			end
		elseif mode == "panel_platform" then
			for i = 1,math.min(#SPlatforms.sorted_platforms, 1024) do
				local l = i - 1
				local yoff = (l % 20) * 10
				local xoff = math.floor(l / 20) * 40
				l = SPlatforms.sorted_platforms[i].polygon.index
				table.insert(menu,
					{ "radio", "pperm_" .. l, 170 + xoff, 190 + yoff, 39, 10, tostring(l) })
			end
		end

		SMenu.inited[mode] = true
	end,

	clickable = function(item_type)
		return item_type == "button" or item_type == "checkbox" or item_type == "radio" or item_type == "texture" or item_type == "light" or item_type == "dbutton" or item_type == "acheckbox" or item_type == "tab"
	end,
}

SChoose = {
	gridsize = function(bct)
		local rows = 1
		local cols = 4
		while (rows * cols) < bct do
			rows = rows + 1
			cols = 2 + (2*rows)
		end
		return rows, math.ceil(bct / rows)
	end,

	widegridsize = function(bct)
		local rows = math.floor(math.sqrt(bct))
		return rows, math.ceil(bct / rows)
	end,
}

SCollections = {
	wall_collections = {},
	landscape_collections = {},
	collection_map = {},
	init = function()

		for _, collection in danger_pairs(WALLS) do
			if Collections[collection] ~= nil and Collections[collection].bitmap_count and (not SCollections.collection_map[collection]) then
				table.insert(SCollections.wall_collections, collection)
				SCollections.collection_map[collection] = {type = "wall", count = Collections[collection].bitmap_count}
			end
		end
		table.sort(SCollections.wall_collections)

		local landscape_textures = {}
		local off = 0
		for _, collection in danger_pairs(LANDSCAPES) do
			if Collections[collection] ~= nil and Collections[collection].bitmap_count and (not SCollections.collection_map[collection]) then
				table.insert(SCollections.landscape_collections, collection)
				SCollections.collection_map[collection] = {type = "landscape", offset = off, count = Collections[collection].bitmap_count}
				off = off + Collections[collection].bitmap_count
				for i = 1,Collections[collection].bitmap_count do
					table.insert(landscape_textures, { collection, i - 1 })
				end
			end
		end
		table.sort(SCollections.landscape_collections)

		local current_collection = SCollections.wall_collections[1]
		local current_light = 0
		if Sides[0] and Sides[0].primary and Sides[0].primary.collection then
			local c = Sides[0].primary.collection.index
			if SCollections.collection_map[c] and SCollections.collection_map[c].type == "wall" then
				current_collection = c
				current_light = Sides[0].primary.light.index
			end
		end
		local current_landscape_collection = SCollections.landscape_collections[1]

		if true then
			local menu_colls = {}
			for _,v in ipairs(SCollections.wall_collections) do
				table.insert(menu_colls, v)
			end
			if #landscape_textures > 0 then table.insert(menu_colls, 0) end

			-- set up collection buttons
			local cbuttons = {}
			if #menu_colls > 0 then
				local n = #menu_colls
				local w = 600 / n

				local x = 20
				local y = 380
				for i = 1,n do
					local cnum = menu_colls[i]
					table.insert(cbuttons,
						{ "dbutton", "coll_" .. cnum, x, y, w, 20, "" })
					x = x + w
				end
			end

			-- set up grid
			for _,cnum in ipairs(menu_colls) do
				local bct
				local xscale = 1
				if cnum == 0 then
					bct = #landscape_textures
					xscale = 2
				else
					bct = Collections[cnum].bitmap_count
				end

				local buttons = {}
				local rows, cols = SChoose.gridsize(bct)
				if xscale == 2 then rows, cols = SChoose.widegridsize(bct) end
				local tsize = math.min(600 / (cols * xscale), 300 / rows)

				for i = 1,bct do
					local col = (i - 1) % cols
					local row = math.floor((i - 1) / cols)
					local x = 20 + (tsize * col * xscale) + (600 - (tsize * cols * xscale))/2
					local y = 80 + (tsize * row) + (300 - (tsize * rows))/2

					local cc = cnum
					local ct = i - 1
					if cnum == 0 then
						cc = landscape_textures[i][1]
						ct = landscape_textures[i][2]
					end
					table.insert(buttons,
						{ "texture", "choose_" .. cc .. "_" .. ct, 
							x, y, tsize * xscale, tsize, cc .. ", " .. ct })
				end
				for _,v in ipairs(cbuttons) do
					table.insert(buttons, v)
				end

				SMenu.menus["choose_" .. cnum] = buttons
			end
		end

		for p in Players() do

			p._collections = {}
			p._collections.current_collection = current_collection
			p._collections.current_landscape_collection = current_landscape_collection
			p._collections.current_textures = {}
			for idx, info in danger_pairs(SCollections.collection_map) do
				p._collections.current_textures[idx] = math.floor(info.count / 2)
			end

			p._light = current_light
			p._transfer_mode = 0

			if p.local_ then
				local pal = p.texture_palette.slots
				for c = 0,31 do
					pal[c].collection = Collections[0]
					local used = SCollections.collection_map[c]
					if used then
						pal[c].texture_index = p._collections.current_textures[c]
						pal[c].type = TextureTypes[used.type]
					else
						pal[c].texture_index = 0
						pal[c].type = TextureTypes["interface"]
					end
				end
				pal[0].texture_index = p._collections.current_landscape_collection
				pal[32].collection = Collections[p._collections.current_collection]
				pal[32].texture_index = p._collections.current_textures[p._collections.current_collection]

				local cur = 0
				for _, collection in danger_pairs(SCollections.wall_collections) do
					pal[cur].collection = Collections[collection]
					cur = cur + 1
				end
				pal[cur].collection = Collections[0]
				cur = cur + 1
				for _, collection in danger_pairs(SCollections.landscape_collections) do
					pal[cur].collection = Collections[collection]
					cur = cur + 1
				end
				pal[cur].collection = Collections[0]
			end
		end
	end,

	update = function()
		for p in Players() do
			if p.local_ then
				local pal = p.texture_palette.slots
				pal[0].texture_index = p._collections.current_landscape_collection
				if p._collections.current_collection == 0 then
					pal[32].collection = 0
					pal[32].texture_index = p._collections.current_textures[p._collections.current_landscape_collection] + SCollections.collection_map[p._collections.current_landscape_collection].offset
				else
					pal[32].collection = p._collections.current_collection
					pal[32].texture_index = p._collections.current_textures[p._collections.current_collection]
				end
				for idx, info in danger_pairs(SCollections.collection_map) do
					pal[idx].texture_index = p._collections.current_textures[idx]
				end
			end
		end
	end,

	set = function(p, coll, tex)
		local ci = SCollections.collection_map[coll]
		if ci == nil then return end
		if ci.type == "landscape" then
			p._collections.current_landscape_collection = coll
			p._collections.current_collection = 0
		else
			p._collections.current_collection = coll
		end
		p._collections.current_textures[coll] = tex
	end,

	find_surface = function(p, copy_mode)
		local surface = nil
		local find_first_line = p._apply.transparent
		local find_first_side = false
		if copy_mode then
			find_first_line = false
			find_first_side = p._apply.transparent
		end
		local o, x, y, z, polygon = VML.find_target(p, find_first_line, find_first_side)
		if is_side(o) then
			o:recalculate_type()
			surface = VML.side_surface(o, z)
		elseif is_polygon_floor(o) or is_polygon_ceiling(o) then
			surface = o
		elseif is_polygon(o) then
			surface = o.floor
		elseif is_line(o) then
			-- we need to make a new side
			surface = VML.side_surface(Sides.new(polygon, o), z)
		end
		return surface, polygon
	end,
}

SUndo = {
	init = function()
		for p in Players() do
			p._undo = {
				undos = {},
				redos = {},
				current = {},
			}
		end
	end,

	update = function()
		for p in Players() do
			local cur_empty = true
			for k, v in danger_pairs(p._undo.current) do
				cur_empty = false
				break
			end
			if not cur_empty then
				-- took undoable actions this frame; push onto undo stack
				table.insert(p._undo.undos, p._undo.current)
				p._undo.current = {}

				-- no redo if last action wasn't undo
				p._undo.redos = {}

				-- limit size of undo stack
				if #p._undo.undos > 64 then
					table.remove(p._undo.undos, 1)
				end
			elseif p._mode == SMode.apply then
				if p._keys.mic.down and p._keys.action.pressed then
					if SUndo.redo_active(p) then
						SUndo.redo(p)
					else
						SUndo.undo(p)
					end
				elseif p._keys.mic.down and p._keys.primary.released then
					if SUndo.undo_active(p) then SUndo.undo(p) end
				elseif p._keys.mic.down and p._keys.secondary.released then
					if SUndo.redo_active(p) then SUndo.redo(p) end
				end
			end
		end
	end,

	undo_active = function(p)
		return #p._undo.undos > 0
	end,

	redo_active = function(p)
		return #p._undo.redos > 0
	end,

	undo = function(p)
		if #p._undo.undos < 1 then return end
		local un = table.remove(p._undo.undos)
		local redo = {}
		for s, f in danger_pairs(un) do
			redo[s] = VML.build_undo(s)
			f()
		end
		table.insert(p._undo.redos, redo)
	end,

	redo = function(p)
		if #p._undo.redos < 1 then return end
		local re = table.remove(p._undo.redos)
		local undo = {}
		for s, f in danger_pairs(re) do
			undo[s] = VML.build_undo(s)
			f()
		end
		table.insert(p._undo.undos, undo)
	end,

	add_undo = function(p, surface)
		if not p._undo.current[surface] then
			p._undo.current[surface] = VML.build_undo(surface)
		end
	end,
}

SCounts = {
	update = function()
		local turn = Game.ticks % 5
		local val = 0

		if turn == 0 then
			val = #Lights
		elseif turn == 1 then
			val = #Polygons
		elseif turn == 2 then
			val = #Platforms
		elseif turn == 3 then
			val = MAX_TAGS
		elseif turn == 4 then
			val = #Terminals
			if val < 1 then val = MAX_SCRIPTS end
		end

		for p in Players() do
			if p.local_ then
				p.texture_palette.slots[33].texture_index = val % 128
				p.texture_palette.slots[34].texture_index = math.floor(val/128)
			end
		end
	end,
}

SLights = {
	update = function()
		for p in Players() do
			if p.local_ then
				for i = 1,math.min(#Lights, MAX_LIGHTS) do
					local slot = p.texture_palette.slots[199 + i]
					if slot then
						slot.texture_index = math.min(199 + MAX_LIGHTS, math.floor(Lights[i - 1].intensity * 128))
					end
				end
			end
		end
	end
}

SPlatforms = {
	sorted_platforms = {},
	index_lookup = {},
	init = function()
		for plat in Platforms() do
			table.insert(SPlatforms.sorted_platforms, plat)
		end
		table.sort(SPlatforms.sorted_platforms, function(a, b) return a.polygon.index < b.polygon.index end)
		for i,v in ipairs(SPlatforms.sorted_platforms) do
			SPlatforms.index_lookup[v.polygon.index] = i
		end
	end,

	update = function()
		local turn = Game.ticks % #Platforms
		local val = 0
		if SPlatforms.sorted_platforms[turn+1] then
			val = SPlatforms.sorted_platforms[turn+1].polygon.index
		end

		for p in Players() do
			if p.local_ then
				p.texture_palette.slots[35].texture_index = val % 128
				p.texture_palette.slots[36].texture_index = math.floor(val/128)
			end
		end
	end,
}

UTeleport = {
	highlight = function(p, poly)
		if not SHOW_TELEPORT_DESTINATION then return end
		if poly ~= p._teleport.last_target then
			UTeleport.remove_highlight(p)
			p._teleport.last_target = poly
			p._teleport.last_target_mode = poly.floor.transfer_mode
			p._teleport.last_target_type = poly.type
			poly.floor.transfer_mode = "static"
			-- poly.type = PolygonTypes["major ouch"]
		end
	end,

	remove_highlight = function(p)
		if not SHOW_TELEPORT_DESTINATION then return end
		if p._teleport.last_target ~= nil then
			-- restore last selected poly
			p._teleport.last_target.floor.transfer_mode = p._teleport.last_target_mode
			p._teleport.last_target.type = p._teleport.last_target_type
			p._teleport.last_target = nil
		end
	end,
}

UApply = {
	apply_texture = function(p, surface, coll, tex, landscape)
		if p._apply.texture then
			surface.collection = coll
			surface.texture_index = tex
			surface.texture_x = p._saved_surface.x
			surface.texture_y = p._saved_surface.y
			if landscape then
				surface.transfer_mode = "landscape"
			elseif p._apply.transfer then
				surface.transfer_mode = transfer_modes[p._transfer_mode + 1]
			end
		elseif p._apply.transfer then
			surface.transfer_mode = transfer_modes[p._transfer_mode + 1]
		end
		if p._apply.light then
			surface.light = Lights[p._light]
		end
	end,

	should_edit_panel = function(p)
		if not p._apply.edit_panels then return false end
		if not p._apply.texture then return false end

		local surface = p._saved_surface.surface
		if surface == nil then return false end
		if is_polygon_floor(surface) or is_polygon_ceiling(surface) then return false end

		local cc = p._collections.current_collection
		if cc == 0 then cc = p._collections.current_landscape_collection end
		local ct = p._collections.current_textures[cc]

		if not SPanel.device_collections[cc] then return false end
		if not SPanel.device_collections[cc][ct] then return false end

		return true
	end,

	should_clear_panel = function(p)
		if not p._apply.edit_panels then return false end
		if not p._apply.texture then return false end

		local surface = p._saved_surface.surface
		if surface == nil then return false end
		if is_polygon_floor(surface) or is_polygon_ceiling(surface) then return false end

		local cc = p._collections.current_collection
		if cc == 0 then cc = p._collections.current_landscape_collection end
		local ct = p._collections.current_textures[cc]

		if not SPanel.device_collections[cc] then return false end
		if not SPanel.device_collections[cc][ct] then return false end

		return true
	end,
}


VML = {
	cw_endpoint_sides = {},
	ccw_endpoint_sides = {},
	init = function()
		local endpoint, side
		for endpoint in Endpoints() do 
			VML.cw_endpoint_sides[endpoint] = {}
			VML.ccw_endpoint_sides[endpoint] = {}
		end
		for side in Sides() do
			table.insert(VML.cw_endpoint_sides[VML.get_clockwise_side_endpoint(side)], side)
			table.insert(VML.ccw_endpoint_sides[VML.get_counterclockwise_side_endpoint(side)], side)
		end
	end,

	quantize_side_center_x = function(player, value, side)
		local ratio = 1.0 / snap_denominators[player._quantize]
		local offset = side.line.length / 2
		return math.floor((value + offset) / ratio + 0.5) * ratio - offset
	end,

	quantize_polygon_center = function(player, value, coordinate)
		local ratio = 1.0 / snap_denominators[player._quantize]
		local offset =  (coordinate * 1024 % 1024) / 1024
		return math.floor((value + offset) / ratio + 0.5) * ratio - offset
	end,

	quantize = function(player, value)
		local ratio = 1.0 / snap_denominators[player._quantize]
		return math.floor(value / ratio + 0.5) * ratio
	end,

	quantize_right = function(player, value, side)
		local ratio = 1.0 / snap_denominators[player._quantize]
		return math.floor((value + side.line.length) / ratio + 0.5) * ratio - side.line.length
	end,

	find_line_intersection = function(line, x0, y0, z0, x1, y1, z1)
		local dx = x1 - x0
		local dy = y1 - y0
		local dz = z1 - z0

		local ldx = line.endpoints[1].x - line.endpoints[0].x
		local ldy = line.endpoints[1].y - line.endpoints[0].y
		local t
		if ldx * dy - ldy * dx == 0 then
			t = 0
		else
			t = (ldx * (line.endpoints[0].y - y0) + ldy * (x0 - line.endpoints[0].x)) / (ldx * dy - ldy * dx)
		end

		return x0 + t * dx, y0 + t * dy, z0 + t * dz
	end,

	find_floor_or_ceiling_intersection = function(height, x0, y0, z0, x1, y1, z1)
		local dx = x1 - x0
		local dy = y1 - y0
		local dz = z1 - z0

		local t
		if dz == 0 then
			t = 0
		else
			t = (height - z0) / dz
		end

		return x0 + t * dx, y0 + t * dy, z
	end,

	overlay_text = function(o)
		local s = tostring(o)
		if string.len(s) > 8 then
			if string.sub(s, 1, 8) == "polygon_" then s = string.sub(s, 9) end -- "polygon_floor" & "polygon_ceiling" are redundant - what other floors or ceilings are there?
		end
		if is_side(o) then
			s = string.format("%s(%c%.4f)", string.sub(s, 6), 198, o.ambient_delta)
		end
		return s
	end,

	do_overlay = function(p, o)
		if o then
			p.overlays[0].text = VML.overlay_text(o)
			p.overlays[0].color = "white"
		end
	end,

	do_transparent_overlay = function(p, o)
		if o then
			p.overlays[1].text = VML.overlay_text(o)
			p.overlays[1].color = "white"
		else
			p.overlays[1]:clear()
		end
	end,

	find_target = function(player, find_first_line, find_first_side)
		local polygon = player.monster.polygon
		local x0, y0, z0 = player.x, player.y, player.z + 0.6
		local x1, y1, z1 = x0, y0, z0
		local dx = math.cos(math.rad(player.pitch)) * math.cos(math.rad(player.yaw))
		local dy = math.cos(math.rad(player.pitch)) * math.sin(math.rad(player.yaw))
		local dz = math.sin(math.rad(player.pitch))

		local line

		player.overlays[1]:clear()

		x1 = x1 + dx
		y1 = y1 + dy
		z1 = z1 + dz
		repeat
			line = polygon:find_line_crossed_leaving(x0, y0, x1, y1)

			if line then
				local x, y, z = VML.find_line_intersection(line, x0, y0, z0, x1, y1, z1)
				if z > polygon.ceiling.height then
					x, y, z = VML.find_floor_or_ceiling_intersection(polygon.ceiling.height, x0, y0, z0, x1, y1, z1)
					VML.do_overlay(player,polygon.ceiling)
					return polygon.ceiling, x, y, z, polygon
				elseif z < polygon.floor.height then
					x, y, z = VML.find_floor_or_ceiling_intersection(polygon.ceiling.height, x0, y0, z0, x1, y1, z1)
					VML.do_overlay(player, polygon.floor)
					return polygon.floor, x, y, z, polygon
				else
					local opposite_polygon
					if line.clockwise_polygon == polygon then
						opposite_polygon = line.counterclockwise_polygon
					elseif line.counterclockwise_polygon == polygon then
						opposite_polygon = line.clockwise_polygon
					end

					if not opposite_polygon or find_first_line then
						-- always stop
						-- locate the side
						if line.clockwise_polygon == polygon then
							if line.clockwise_side then
								VML.do_overlay(player, line.clockwise_side)
								return line.clockwise_side, x, y, z, polygon
							else
								VML.do_overlay(player, line)
								return line, x, y, z, polygon
							end
						else
							if line.counterclockwise_side then
								VML.do_overlay(player, line.counterclockwise_side)
								return line.counterclockwise_side, x, y, z, polygon
							else
								VML.do_overlay(player, line)
								return line, x, y, z, polygon
							end
						end
					elseif find_first_side and line.has_transparent_side then
						if line.clockwise_polygon == polygon then
							VML.do_overlay(player, line.clockwise_side)
							return line.clockwise_side, x, y, z, polygon
						else
							VML.do_overlay(player, line.counterclockwise_side)
							return line.counterclockwise_side, x, y, z, polygon
						end
					else
						if line.has_transparent_side then
							if line.clockwise_polygon == polygon then
								VML.do_transparent_overlay(player, line.clockwise_side)
							else
								VML.do_transparent_overlay(player, line.counterclockwise_side)
							end
						end
						-- can we pass
						if z < opposite_polygon.floor.height or z > opposite_polygon.ceiling.height then
							if line.clockwise_polygon == polygon then
								if line.clockwise_side then
									VML.do_overlay(player, line.clockwise_side)
									return line.clockwise_side, x, y, z, polygon
								else
									VML.do_overlay(player, line)
									return line, x, y, z, polygon
								end
							else
								if line.counterclockwise_side then
									VML.do_overlay(player, line.counterclockwise_side)
									return line.counterclockwise_side, x, y, z, polygon
								else
									VML.do_overlay(player, line)
									return line, x, y, z, polygon
								end
							end
						else
							-- pass
							polygon = opposite_polygon
						end
					end
				end
			else
				-- check if we hit the floor, or ceiling
				if z1 > polygon.ceiling.height then
					local x, y, z = VML.find_floor_or_ceiling_intersection(polygon.ceiling.height, x0, y0, z0, x1, y1, z1)
					VML.do_overlay(player, polygon.ceiling)
					return polygon.ceiling, x, y, z, polygon
				elseif z1 < polygon.floor.height then
					local x, y, z = VML.find_floor_or_ceiling_intersection(polygon.floor.height, x0, y0, z0, x1, y1, z1)
					VML.do_overlay(player, polygon.floor)
					return polygon.floor, x, y, z, polygon
				else
					x1 = x1 + dx
					y1 = y1 + dy
					z1 = z1 + dz
				end
			end
		until x1 > 32 or x1 < -32 or y1 > 32 or y1 < -32 or z1 > 32 or z1 < -32
		-- uh oh
		VML.do_overlay(player, nil)
		-- print("POOP!")
		return nil
	end,

	get_clockwise_side_endpoint = function(side)
		local line_is_clockwise = true
		if side.line.clockwise_polygon ~= side.polygon then
			-- counterclockwise line
			return side.line.endpoints[0]
		else
			return side.line.endpoints[1]
		end
	end,

	get_counterclockwise_side_endpoint = function(side)
		local line_is_clockwise = true
		if side.line.clockwise_polygon ~= side.polygon then
			-- counterclockwise line
			return side.line.endpoints[1]
		else
			return side.line.endpoints[0]
		end
	end,

	side_surface = function(side, z)
		if side.type == "full" then
			local opposite_polygon
			if side.line.clockwise_side == side then
				opposite_polygon = side.line.counterclockwise_polygon
			else
				opposite_polygon = side.line.clockwise_polygon
			end
			if opposite_polygon then
				return side.transparent
			else
				return side.primary
			end
		elseif side.type == "high" then
			if z > side.line.lowest_adjacent_ceiling then
				return side.primary
			else
				return side.transparent
			end
		elseif side.type == "low" then
			if z < side.line.highest_adjacent_floor then
				return side.primary
			else
				return side.transparent
			end
		else
			if z > side.line.lowest_adjacent_ceiling then
				return side.primary
			elseif z < side.line.highest_adjacent_floor then
				return side.secondary
			else
				return side.transparent
			end
		end
	end,

	surface_heights = function(surface)
		local side = Sides[surface.index]
		if is_primary_side(surface) then
			if side.type == "full" then
				return side.polygon.floor.height, side.polygon.ceiling.height
			elseif side.type == "low" then
				return side.polygon.floor.height, side.line.highest_adjacent_floor
			else
				return side.line.lowest_adjacent_ceiling, side.polygon.ceiling.height
			end
		elseif is_secondary_side(surface) then
			if side.type == "split" then
				return side.polygon.floor.height, side.line.highest_adjacent_floor
			else
				return nil
			end
		else -- transparent
			if side.type == "full" then
				return side.polygon.floor.height, side.polygon.ceiling.height
			elseif side.type == "low" then
				return side.line.highest_adjacent_floor, side.polygon.ceiling.height
			elseif side.type == "high" then
				return side.polygon.floor.height, side.line.lowest_adjacent_ceiling
			else -- split
				return side.line.highest_adjacent_floor, side.line.lowest_adjacent_ceiling
			end
		end
	end,

	build_undo = function(surface)
		local collection = surface.collection
		local texture_index = surface.texture_index
		local transfer_mode = surface.transfer_mode
		local light = surface.light
		local texture_x = surface.texture_x
		local texture_y = surface.texture_y
		local empty = is_transparent_side(surface) and surface.empty
		local device
		if is_primary_side(surface) then
			local side = Sides[surface.index]
			if side.control_panel then
				device = {}
				device.device = side.control_panel.type
				device.light_dependent = side.control_panel.light_dependent
				device.permutation = side.control_panel.permutation
				device.only_toggled_by_weapons = side.control_panel.only_toggled_by_weapons
				device.repair = side.control_panel.repair
				device.status = side.control_panel.status
			end
		end
		local function undo()
			if empty then
				surface.empty = true
			else
				if collection then
					surface.collection = collection
				end
				surface.texture_index = texture_index
				surface.transfer_mode = transfer_mode
				surface.light = light
				if device then
					VML.save_control_panel(Sides[surface.index], device)
				elseif is_primary_side(surface) then
					Sides[surface.index].control_panel = false
				end
			end
			surface.texture_x = texture_x
			surface.texture_y = texture_y
		end
		return undo
	end,

	undo = function(player)
		if not player._undo then return end
		local redo = {}
		for s, f in danger_pairs(player._undo) do
			redo[s] = build_undo(s)
			f()
		end
		player._undo = redo
	end,

	valid_surfaces = function(side)
		local surfaces = {}
		if side.type == "split" then
			table.insert(surfaces, side.primary)
			table.insert(surfaces, side.secondary)
			table.insert(surfaces, side.transparent)
		elseif side.type == "full" then
			table.insert(surfaces, side.primary)
		else
			table.insert(surfaces, side.primary)
			table.insert(surfaces, side.transparent)
		end
		return surfaces
	end,

	build_side_offsets_table = function(first_surface)
		local surfaces = {}
		local offsets = {} -- surface -> offset

		table.insert(surfaces, first_surface)
		offsets[first_surface] = 0

		while # surfaces > 0 do
			-- remove the first surface
			local surface = table.remove(surfaces, 1)
			local low, high = VML.surface_heights(surface)

			local side = Sides[surface.index]

			-- consider neighboring surfaces on this side
			local neighbors = {}

			if side.type == "split" then
				if is_transparent_side(surface) then
					table.insert(neighbors, side.primary)
					table.insert(neighbors, side.secondary)
				else
					-- check for "joined" split
					local bottom, top = VML.surface_heights(side.transparent)
					if bottom == top then
						if is_primary_side(surface) then
							table.insert(neighbors, side.secondary)
						else
							table.insert(neighbors, side.primary)
						end
					else
						table.insert(neighbors, side.transparent)
					end
				end
			elseif side.type ~= "full" then
				if is_primary_side(surface) then
					table.insert(neighbors, side.transparent)
				elseif is_transparent_side(surface) then
					table.insert(neighbors, side.primary)
				end
			end

			for _, neighbor in danger_pairs(neighbors) do
				if offsets[neighbor] == nil 
					and surface.texture_index == neighbor.texture_index
					and surface.collection == neighbor.collection
				then
					offsets[neighbor] = offsets[surface]
					table.insert(surfaces, neighbor)
				end
			end

			local line = Sides[surface.index].line
			local length = line.length
			-- consider any clockwise adjacent surfaces within our height range
			for _, side in danger_pairs(VML.ccw_endpoint_sides[VML.get_clockwise_side_endpoint(Sides[surface.index])]) do
				if side.line ~= line then
					for _, neighbor_surface in danger_pairs(VML.valid_surfaces(side)) do
						local bottom, top = VML.surface_heights(neighbor_surface)
						if offsets[neighbor_surface] == nil
						   and neighbor_surface.texture_index == surface.texture_index
						   and neighbor_surface.collection == surface.collection
						   and high > bottom and top > low
						then
							offsets[neighbor_surface] = offsets[surface] + length
							table.insert(surfaces, neighbor_surface)
						end
					end
				end
			end

			-- consider any counterclockwise adjacent surfaces within our height range
			for _, side in danger_pairs(VML.cw_endpoint_sides[VML.get_counterclockwise_side_endpoint(Sides[surface.index])]) do

				if side.line ~= line then
					for _, neighbor_surface in danger_pairs(VML.valid_surfaces(side)) do
						local bottom, top = VML.surface_heights(neighbor_surface)
						if offsets[neighbor_surface] == nil
						   and neighbor_surface.texture_index == surface.texture_index
						   and neighbor_surface.collection == surface.collection
						   and high > bottom and top > low
						then
							offsets[neighbor_surface] = offsets[surface] - side.line.length
							table.insert(surfaces, neighbor_surface)
						end
					end
				end
			end
		end

		return offsets
	end,

	align_sides = function(surface, offsets)
		local x = surface.texture_x
		local y = surface.texture_y
		local _, top = VML.surface_heights(surface)

		for surface, offset in danger_pairs(offsets) do
			local _, new_top = VML.surface_heights(surface)
			surface.texture_x = x + offset
			surface.texture_y = y + top - new_top
		end
	end,

	build_polygon_align_table = function(polygon, surface)
		local polygons = {}
		local accessor
		if is_polygon_floor(surface) then
			accessor = "floor"
		else
			accessor = "ceiling"
		end

		local function recurse(p)
			if not polygons[p] -- already visited
			   and p[accessor].texture_index == surface.texture_index 
			   and p[accessor].collection == surface.collection 
			   and p[accessor].z == surface.z
			then
				-- add this polygon, and search for any adjacent
				polygons[p] = true
				for adjacent in p:adjacent_polygons() do
					recurse(adjacent)
				end
			end
		end

		recurse(polygon)
		return polygons
	end,

	align_polygons = function(surface, align_table)
		local x = surface.texture_x
		local y = surface.texture_y
		
		local accessor
		if is_polygon_floor(surface) then
			accessor = "floor"
		else
			accessor = "ceiling"
		end
		for p in danger_pairs(align_table) do
			p[accessor].texture_x = x
			p[accessor].texture_y = y
		end
	end,

	is_switch = function(device)
		return device.class == "light switch" or device.class == "tag switch" or device.class == "platform switch"
	end,

	save_control_panel = function(side, device)
		side.control_panel = true
		side.control_panel.light_dependent = device.light_dependent
		side.control_panel.permutation = device.permutation
		if VML.is_switch(device.device) then
			side.control_panel.only_toggled_by_weapons = device.only_toggled_by_weapons
			side.control_panel.repair = device.repair
			side.control_panel.can_be_destroyed = (device.device._type == SPanel.wires)
			side.control_panel.uses_item = (device.device._type == SPanel.chip)
			if device.device.class == "light switch" then
				side.control_panel.status = Lights[side.control_panel.permutation].active
			elseif device.device.class == "platform_switch" then
				side.control_panel.status = Polygons[side.control_panel.permutation].platform.active
			else
				side.control_panel.status = device.status
			end
		else
			side.control_panel.only_toggled_by_weapons = false
			side.control_panel.repair = false
			side.control_panel.can_be_destroyed = false
			side.control_panel.uses_item = false
			side.control_panel.status = false
		end
		side.control_panel.type = device.device
	end,
}
