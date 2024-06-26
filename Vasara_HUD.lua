-- Vasara AF 1.0b (HUD script)
-- by Hopper, Ares Ex Machina, Aaron Freed, CryoS, and Solra Bizna

-- see line 109 for preferences (the code below needs to execute *first*)

-- Copyright 2023 Solra Bizna. I expressly authorize you (the reader) to use
-- this script, change it to fit your needs, strip out my name and claim it as
-- your own, whatever. This copyright claim is solely to assert authorship long
-- enough to immediately disclaim all copy-rights.

load_order = load_order or {}
table.insert(load_order, "00129.txt (-a1-lua-shim.lua)")

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
						debug_print("Error in Triggers."..key..":\n"..result, true)
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
	setmetatable(Game, {
		__index=RealGame,
		__newindex=RealGame,
	})
end

-- PREFERENCES

-- Preview full collections on Choose or Visual Mode screens
-- (set one or both to false to spend less time "Loading textures...")
preview_all_collections = true
preview_collection_when_applying = true

-- Displayed names for texture collections
collection_names = {
[0] = "Landscapes",
[17] = "Water",
[18] = "Lava",
[19] = "Sewage",
[20] = "Jjaro",
[21] = "Pfhor"
}

-- colors (RGBA, 0 to 1)
colors = {
	menu_label = { 0.7, 0.7, 0.3, 1 },
	current_texture = { 0, 7/9, 0, 1 },
	snap_grid = { 0, 1, 0, 0.6 },

	light = {
		enabled={frame={0.5, 0.5, 0.5, 1}, text={0.8, 0.8, 0.8, 1},},
		active ={frame={0,   1,   0,   1}, text={0.2, 1.0, 0.2, 1},},
	},

	commands = {
		enabled ={label={0.7, 0.7, 0.3, 1}, key={1,   1,   1,   1},},
		disabled={label={0.4, 0.4, 0.2, 1}, key={0.5, 0.5, 0.5, 1},},
		active  ={label={0.2, 1.0, 0.2, 1}, key={0.2, 1.0, 0.2, 1},},
	},

	button = {
		enabled ={background={0.1, 0.1, 0.1, 1}, highlight={0.08, 0.08, 0.08, 1}, shadow={0.12, 0.12, 0.12, 1}, text={0.8, 0.8, 0.8, 1},},
		disabled={background={0.1, 0.1, 0.1, 1}, highlight={0.08, 0.08, 0.08, 1}, shadow={0.12, 0.12, 0.12, 1}, text={0.4, 0.4, 0.4, 1},},
		active  ={background={0.2, 0.2, 0.2, 1}, highlight={0.25, 0.25, 0.25, 1}, shadow={0.15, 0.15, 0.15, 1}, text={0.0, 1.0, 0.0, 1},},
	},

	apply = {
		enabled={background={0.0, 0.0, 0.0, 1}, highlight={0.0, 0.0, 0.0, 1}, shadow={0.0, 0.0, 0.0, 1}, text={0.5, 0.5, 0.5, 1},},
		active ={background={0.0, 0.0, 0.0, 1}, highlight={0.0, 0.0, 0.0, 1}, shadow={0.0, 0.0, 0.0, 1}, text={1,   1,   1,   1},},
	},

	teleport = {
		poly_background = { 0.0, 0.0, 0.0, 0.6 },
		poly_text = { 1, 1, 1, 1 },
		poly_text_active = { 0.2, 1, 0.2, 1 },
	},

	ktab = {
		background = { 0.15, 0.15, 0.15, 1 },
		current ={background={0.15, 0.15, 0.15, 1}, text={0.2, 1.0, 0.2, 1}, label={0,   0,   0,   0},},
		enabled ={background={0.1,  0.1,  0.1,  1}, text={0.8, 0.8, 0.8, 1}, label={0.7, 0.7, 0.3, 1},},
		disabled={background={0.1,  0.1,  0.1,  1}, text={0.4, 0.4, 0.4, 1}, label={0.4, 0.4, 0.2, 1},},
		active  ={background={0.1,  0.1,  0.1,  1}, text={0.2, 1.0, 0.2, 1}, label={0.2, 1.0, 0.2, 1},},
	},

	tab = {
		background = { 0.1, 0.1, 0.1, 1 },
		enabled ={background={0.06, 0.06, 0.06, 1}, text={0.8, 0.8, 0.8, 1},},
		disabled={background={0.06, 0.06, 0.06, 1}, text={0.4, 0.4, 0.4, 1},},
		active  ={background={0.1,  0.1,  0.1,  1}, text={0.2, 1.0, 0.2, 1},},
	},
}

-- other menu UI prefs
MENU_BUTTON_INDENT = 1

menu_prefs = {
	button_indent = MENU_BUTTON_INDENT,
	button_highlight_thickness = 2,
	button_shadow_thickness = 2,

	tab_indent = {
		top = MENU_BUTTON_INDENT,
		bottom = MENU_BUTTON_INDENT,
		left = 0,
		right = 2*MENU_BUTTON_INDENT,
		band_left = 7
	},

	texture_choose_indent = 1,
	texture_apply_indent = 0.5,
	texture_preview_indent = 0,

	light_thickness = 1,

	preview = {
		apply = { light_border = 2, snap_grid = 0, },
		attribute = { light_border = 4, snap_grid = 1, },
	},
}

DEBUG_MODE = false -- set to true to tell me when a nil value is getting sent to hasbit

-- END PREFERENCES -- no user serviceable parts below ;)

MAX_LIGHTS = 98 -- more than this will cause the script to freak out

Triggers = {}

g_scriptChecked = false
g_initMode = 0

snap_denominators = { 1, 2, 3, 4, 5, 6, 8, 10, 12, 16, 18, 20, 24, 30, 32, 36, 40, 48, 60, 64, 128 }
snap_modes = { 1 }
for _,d in ipairs(snap_denominators) do
	if d ~= 1 then table.insert(snap_modes, "1/" .. d) end
end

function debug_print(str, is_error)
	if DEBUG_MODE or is_error then
		local keep_printing = true -- whether we need to keep printing
		local start_of_line = 1 -- place to start searching
		local line_count = 0 -- line to start printing on
		if DEBUG_MODE and is_error then line_count = 1 end
		local length = string.len(str)
		repeat
			local end_of_line = math.min(string.find(str, "\n", start_of_line + 1) or length,
			                             string.find(str, "\f", start_of_line + 1) or length,
			                             string.find(str, "\r", start_of_line + 1) or length,
			                             start_of_line + 160,
			                             length)
			HGlobals.fontn:draw_text(string.sub(str,
			                                    start_of_line,
			                                    end_of_line
			                                   ),
			                         Screen.world_rect.x + 10,
			                         Screen.world_rect.y + ((line_count + 1) * 20),
			                         {1, 1, 1, 1}
			                        )
			if end_of_line ~= length then
				line_count = line_count + 1
				start_of_line = end_of_line
			else
				keep_printing = false
			end
		until not keep_printing
	end
end

function Triggers.draw()
	if Player.life ~= 409 then
		if not g_scriptChecked then
			g_scriptChecked = true
			error "Vasara HUD requires Vasara Script"
		end
		return
	end

	if g_initMode < 2 then
		if g_initMode == 1 then
			HCollections.update()
			HMenu.draw_menu("choose_" .. HCollections.current_collection)
		end
		Screen.fill_rect(0, 0, Screen.width, Screen.height, { 0, 0, 0, 1 })
		local txt = "Loading textures..."
		local fw, fh = HGlobals.fontn:measure_text(txt)
		HGlobals.fontn:draw_text(txt,
			Screen.width/2 - fw/2, Screen.height/2 - fh/2,
			{ 1, 1, 1, 1 })
		g_initMode = g_initMode + 1
		print("Loading textures...")
		return
	end

	HMode.update()
	HKeys.update()
	HApply.update()
	HStatus.update()
	HCollections.update()
	HCounts.update()
	HLights.update()
	HPlatforms.update()
	HTeleport.update()
	HPanel.update()

	if HMode.changed then layout() end

	-- keys
	if HMode.is(HMode.panel) then
		HMenu.draw_menu("key_" .. HPanel.menu_name(), true)
	else
		if not (HStatus.down(HStatus.advanced_active) and (HMode.is(HMode.apply) or HMode.is(HMode.teleport))) then
			HMenu.draw_menu("key_" .. HMode.current, true)
		end
	end

	-- teleport notices
	if HMode.is(HMode.teleport) then
		local yp = HGlobals.cpos[2]
		local xp = HGlobals.cpos[1]

		local fw, fh = HGlobals.fontn:measure_text(HTeleport.poly)
		local xf = xp - fw/2
		local yf = yp - fh - 15*HGlobals.scale
		Screen.fill_rect(xf - 5*HGlobals.scale, yf, fw + 10*HGlobals.scale, fh, colors.teleport.poly_background)
		local clr = colors.teleport.poly_text
		if (not HKeys.down(HKeys.mic)) and HKeys.down(HKeys.primary) then
			clr = colors.teleport.poly_text_active
		end
		HGlobals.fontn:draw_text(HTeleport.poly, xf, yf, clr)

		if not Screen.map_overlay_active then
			HGlobals.fontn:draw_text("Enable Overlay Map in Preferences --> Graphics for correct behavior",
				Screen.world_rect.x + 10*HGlobals.scale,
				Screen.world_rect.y + Screen.world_rect.height - 2*HGlobals.fheight,
				{ 0, 1, 0, 1 })
		end
	end

	-- menus
	if HMode.is(HMode.attribute) or HMode.is(HMode.panel) or HMode.is(HMode.choose) then
		local m = HMode.current
		if HMode.is(HMode.choose) then
			m = "choose_" .. HCollections.current_collection
		elseif HMode.is(HMode.panel) then
			m = HPanel.menu_name()
		end
		if HMenu.menus[m] then
			HMenu.draw_menu(m)
		end
	end

	-- lower area
	if HMode.is(HMode.apply) then
		local xp = HGlobals.xoff + 20*HGlobals.scale
		local yp = HGlobals.yoff + (320+72)*HGlobals.scale

		-- lower left: current texture, attributes
		local lbls = HMenu.menus["apply_options"]
		if HApply.current_light then lbls[1][7] = "Apply light: " .. HApply.current_light else lbls[1][7] = "Apply light: [out of display range]" end

		local att = ""
		if HApply.down(HApply.use_texture) and HApply.use_transfer == 1 then
			att = "Apply texture & transfer mode"
		elseif HApply.down(HApply.use_texture) then
			att = "Apply texture"
		elseif HApply.use_transfer == 1 then
			att = "Apply transfer mode"
		else
			att = "Texture & transfer mode disabled"
		end
		local tmode = HApply.transfer_modes[HApply.current_transfer + 1]
		--[[if HCollections.current_collection == 0 then
			if HApply.current_transfer == 5 then tmode = nil end
		else
			if HApply.current_transfer == 0 then tmode = nil end
		end--]]
		if tmode ~= nil and HApply.use_transfer == 1 then
			att = att .. ": " .. tmode
		end
		lbls[2][7] = att

		if HApply.down(HApply.transparent) then
			if Level.stash["decouple"] == "TRUE" then
				lbls[5][7] = "Edit transparent side (decoupled from reverse)"
			else
				lbls[5][7] = "Edit transparent sides (coupled with reverse)"
			end
		else
			lbls[5][7] = "Ignore transparent sides"
		end

		if HApply.snap_x or HApply.snap_y then
			local snap_axes = ""
			if HApply.snap_x and HApply.snap_y then
				snap_axes = "X & Y"
			elseif HApply.snap_x then
				snap_axes = "X"
			else
				snap_axes = "Y"
			end
			local iu = 1024 / snap_denominators[HApply.current_snap]
			local ch = string.format("%c", 197)
			if iu == math.floor(iu) then ch = "=" end
			if HApply.current_snap_mode == 0 then
				local snap_dirs = ""
				if HApply.snap_x and HApply.snap_y then
					snap_dirs = "top-left"
				elseif HApply.snap_x then
					snap_dirs = "left"
				elseif HApply.snap_y then
					snap_dirs = "top"
				end
				lbls[6][7] = string.format(
					"Snap: %s %c n%s WU %s %d IU (absolute %s)",
					snap_dirs,
					177,
					string.sub(snap_modes[HApply.current_snap], 2),
					ch,
					iu,
					snap_axes
				)
			elseif HApply.current_snap_mode == 1 then
				if HApply.snap_x and HApply.snap_y then
					snap_dirs = "northwest/upper left"
				elseif HApply.snap_x then
					snap_dirs = "west/left"
				elseif HApply.snap_y then
					snap_dirs = "north/top"
				end
				lbls[6][7] = string.format(
					"Snap: %s %c n%s WU %s %d IU (relative %s)",
					snap_dirs,
					177,
					string.sub(snap_modes[HApply.current_snap], 2),
					ch,
					iu,
					snap_axes
				)
			elseif HApply.current_snap_mode == 2 then
				lbls[6][7] = string.format(
					"Snap: centre %c n%s WU %s %d IU (relative %s)",
					177,
					string.sub(snap_modes[HApply.current_snap], 2),
					ch,
					iu,
					snap_axes
				)
			elseif HApply.current_snap_mode == 3 then
				local snap_dirs = ""
				if HApply.snap_x and HApply.snap_y then
					snap_dirs = "southeast/lower right"
				elseif HApply.snap_x then
					snap_dirs = "east/right"
				elseif HApply.snap_y then
					snap_dirs = "south/bottom"
				end
				lbls[6][7] = string.format(
					"Snap: %s %c n%s WU %s %d IU (relative %s)",
					snap_dirs,
					177,
					string.sub(snap_modes[HApply.current_snap], 2),
					ch,
					iu,
					snap_axes
				)
			end
		else
			lbls[6][7] = "Grid snap disabled"
		end

		HMenu.draw_menu("apply_options", true)

		-- lower right: full collection
		HMenu.draw_menu("preview_" .. HCollections.current_collection, true)
	end

	-- cursor
	draw_cursor()
end

function draw_mode(label, x, y, active)
	local clr = colors.apply.enabled.text
	local img = imgs["fcheck_off"]
	if active then
		clr = colors.apply.active.text
		img = imgs["fcheck_on"]
	end
	img:draw(x - 2*HGlobals.scale, y)
	HGlobals.fontn:draw_text(label, x + 13*HGlobals.scale, y, clr)
end

function draw_cursor()
	local cname = "menu"
	if HMode.is(HMode.apply) then
		cname = "apply"
	elseif HMode.is(HMode.teleport) then
		cname = "teleport"
	end
	if HKeys.down(HKeys.primary) and (not HKeys.down(HKeys.mic)) then
		cname = cname .. "_down"
	end
	if HKeys.down(HKeys.secondary) and (not HKeys.down(HKeys.mic)) and HMode.is(HMode.apply) then
		cname = cname .. "_down2"
	end

	local x = (HStatus.cursor_x*HGlobals.scale) + HGlobals.xoff
	local y = (HStatus.cursor_y*HGlobals.scale) + HGlobals.yoff
	local im = imgs["cursor_" .. cname]
	if im then im:draw(x - HGlobals.coff[1], y - HGlobals.coff[2]) end
end

imgs = {}
function Triggers.init()
	Screen.crosshairs.lua_hud = true
	g_initMode = 0

	for _, nm in danger_pairs({ "cursor_menu", "cursor_menu_down",
	                            "cursor_apply", "cursor_apply_down", "cursor_apply_down2",
	                            "cursor_teleport", "cursor_teleport_down",
	                            "bracket_on", "bracket_off", "bracket_dis",
	                            "dcheck_on", "dcheck_off", "dcheck_dis",
	                            "dradio_on", "dradio_off", "dradio_dis",
	                            "fcheck_on", "fcheck_off" }) do
		imgs[nm] = Images.new{path = "resources/" .. nm .. ".png"}
	end
	img_static = Images.new{path = "resources/static.png"}

	Triggers.resize()
end

HGlobals = {}
function Triggers.resize()
	HGlobals.scale = math.min(Screen.width / 640, Screen.height / 480)
	HGlobals.xoff = math.floor((Screen.width - (640 * HGlobals.scale)) / 2)
	HGlobals.yoff = math.floor((Screen.height - (480 * HGlobals.scale)) / 2)

	HGlobals.fontb = Fonts.new{file = "dejavu/DejaVuLGCSansCondensed-Bold.ttf", size = 12 * HGlobals.scale}
	HGlobals.fontn = Fonts.new{file = "dejavu/DejaVuLGCSansCondensed-Bold.ttf", size = 9 * HGlobals.scale}
	HGlobals.fontm = Fonts.new{file = "dejavu/DejaVuLGCSansCondensed-Bold.ttf", size = 7 * HGlobals.scale}

	HGlobals.fwidth, HGlobals.fheight = HGlobals.fontn:measure_text("  ")
	HGlobals.bwidth, HGlobals.bheight = HGlobals.fontb:measure_text("  ")
	HGlobals.mwidth, HGlobals.mheight = HGlobals.fontm:measure_text("  ")
	HGlobals.fnoff = 0 - HGlobals.fheight/2
	HGlobals.fmoff = 0 + HGlobals.fheight/2 - HGlobals.mheight

	for _, i in danger_pairs(imgs) do
		rescale(i, HGlobals.scale / 3)
	end

	layout()
end

function rescale(img, scale)
	if not img then return end
	local w = math.max(1, img.unscaled_width * scale)
	local h = math.max(1, img.unscaled_height * scale)
	img:rescale(w, h)
end

function layout()
	local x = HGlobals.xoff
	local y = HGlobals.yoff
	local w = 640*HGlobals.scale
	local h = 480*HGlobals.scale
	local header = 72
	if HStatus.down(HStatus.advanced_active) and (HMode.is(HMode.apply) or HMode.is(HMode.teleport)) then
		header = 0
		x = 0
		w = Screen.width
	end

	Screen.clip_rect.x = x
	Screen.clip_rect.y = y
	Screen.clip_rect.width = w
	Screen.clip_rect.height = h

	y = y + header*HGlobals.scale
	h = (392 - header)*HGlobals.scale

	Screen.term_rect.x = x
	Screen.term_rect.y = y
	Screen.term_rect.width = w
	Screen.term_rect.height = h

	local halfh = math.floor((480 - header)*HGlobals.scale/2)
	Screen.map_rect.x = x
	Screen.map_rect.y = y + halfh
	Screen.map_rect.width = w
	Screen.map_rect.height = halfh

	if Screen.map_active then
		local halfw = halfh * 2
		Screen.world_rect.x = x + (w - halfw)/2
		Screen.world_rect.y = y
		Screen.world_rect.width = halfw
		Screen.world_rect.height = halfh
	else
		local fullw = math.min(w, h * 2)
		Screen.world_rect.x = x + (w - fullw)/2
		Screen.world_rect.y = y
		Screen.world_rect.width = fullw
		Screen.world_rect.height = h
	end

	HGlobals.cpos = {
		Screen.world_rect.x + Screen.world_rect.width/2,
		Screen.world_rect.y + Screen.world_rect.height/2 }

	HGlobals.coff = { imgs["cursor_menu"].width/2,
	                  imgs["cursor_menu"].height/2 }
end

function hasbit(yourmom, which)
	-- if not yourmom then return true end -- i dunno why but this is necessary
	local test = 2 ^ (which - 1)
	return (yourmom % (test + test) >= test)
end

function PIN(v, min, max)
	if v < min then return min end
	if v > max then return max end
	return v
end

HKeys = {
	bitfield = 0,
	primary = 1,
	secondary = 2,
	mic = 3,
	prev_weapon = 4,
	next_weapon = 5,
	action = 6,
	map = 7,
	dummyfield = 0,
	names = {"Trigger", "2nd Trigger", "Auxiliary Trigger", "Previous Weapon", "Next Weapon", "Action", "Auto Map"},
	shortnames = {"Trigger", "2nd", "Aux", "Prev", "Next", "Action", "Map"},

	update = function()
		HKeys.bitfield = Player.texture_palette.slots[39].texture_index
		-- HKeys.dummyfield = Player.texture_palette.slots[42].texture_index
	end,

	down = function(k)
		if HKeys.bitfield == nil then
			debug_print(string.format("HKeys.bitfield in HKeys.down for %u", k), false)
		end
		return hasbit(HKeys.bitfield, k)
	end,

	dummy = function(k)
		if HKeys.bitfield == nil then
			debug_print(string.format("HKeys.dummyfield in HKeys.dummy for %u", k), false)
		end
		return hasbit(HKeys.dummyfield, k)
	end,

	button_state = function(keyname, mic_modifier)
		local state = "enabled"

		if keyname == "any" then
			if mic_modifier then
				if not HKeys.down(HKeys.mic) then
					state = "disabled"
				elseif HKeys.down(HKeys.prev_weapon) or
				       HKeys.down(HKeys.next_weapon) or
				       HKeys.down(HKeys.primary) or
				       HKeys.down(HKeys.secondary) then
					state = "active"
				end
			elseif HKeys.down(HKeys.mic) then
				state = "disabled"
			end
		elseif keyname == "weapon" then
			if HKeys.down(HKeys.prev_weapon) or HKeys.down(HKeys.next_weapon) then state = "active" end

			if HKeys.down(HKeys.mic) ~= mic_modifier then state = "disabled" end
		elseif keyname == "move" then
			-- this isn't true, but it looks a lot nicer visually
			if HKeys.down(HKeys.mic) ~= mic_modifier then state = "disabled" end
		else
			local k = HKeys[keyname]
			if HKeys.down(k) then state = "active" end

			if k == HKeys.mic then
				if HKeys.dummy(HKeys.mic) then state = "disabled" end
			elseif mic_modifier then
				if not HKeys.down(HKeys.mic) then state = "disabled" end
			elseif HKeys.down(HKeys.mic) then
				state = "disabled"
			elseif k == HKeys.action and (HMode.is(HMode.apply) or HMode.is(HMode.teleport)) and HStatus.down(HStatus.action_active) then
				state = "disabled"
			end
		end

		return state
	end,
}

HApply = {
	bitfield = 0,
	use_texture = 1,
	use_light = 2,
	align = 3,
	transparent = 4,
	edit_panels = 5,
	current_light = 0,
	current_transfer = 0,
	transfer_modes = {
		"Normal", "Pulsate", "Wobble", "Fast wobble", "Static", "Landscape",
		"Horizontal slide", "Fast horizontal slide", "Vertical slide", "Fast vertical slide", "Wander", "Fast wander",
		"Reverse horizontal slide", "Reverse fast horizontal slide", "Reverse vertical slide", "Reverse fast vertical slide", "2x", "4x"
	},

	update = function()
		HApply.bitfield = Player.texture_palette.slots[46].texture_index
		HApply.current_light = Player.texture_palette.slots[43].texture_index
		HApply.current_transfer = Player.texture_palette.slots[44].texture_index
		HApply.use_transfer = Player.texture_palette.slots[44].type
		HApply.current_snap = Player.texture_palette.slots[45].texture_index
		HApply.current_snap_mode = Player.texture_palette.slots[45].type
		if Player.texture_palette.slots[46].texture_index == nil then
			debug_print("Player.texture_palette.slots[46].texture_index in HApply.update")
		end
		HApply.realign = (Level.stash["realign"] == "TRUE")
		HApply.snap_x = (Level.stash["snap_x"] == "TRUE")
		HApply.snap_y = (Level.stash["snap_y"] == "TRUE")

		local lbls = HMenu.menus["key_" .. HMode.apply]
		local lbls2 = HMenu.menus["key_" .. HMode.attribute]

		lbls2[9][7] = "Apply Light Only"
		if HApply.down(HApply.use_texture) then
			if HApply.down(HApply.use_light) then
				lbls[2][7] = "Apply Light + Texture"
			else
				lbls[2][7] = "Apply Texture"
			end
		elseif HApply.down(HApply.use_light) then
			lbls[2][7] = "Apply Light"
			lbls2[9][7] = "Apply Texture Only"
		else
			lbls[2][7] = "Move Texture"
		end
	end,

	down = function(k)
		if HKeys.bitfield == nil then
			debug_print(string.format("HApply.bitfield in HApply.down for %u", k), false)
		end
		return hasbit(HApply.bitfield, k)
	end,
}

HStatus = {
	bitfield = 0,
	frozen = 1,
	undo_active = 2,
	redo_active = 3,
	action_active = 4,
	advanced_active = 5,
	current_menu_item = 0,
	cursor_x = 0,
	cursor_y = 0,

	update = function()
		HStatus.bitfield = Player.texture_palette.slots[41].texture_index
		HStatus.current_menu_item = Player.texture_palette.slots[47].texture_index
		HStatus.cursor_x = Player.texture_palette.slots[54].texture_index + 128*Player.texture_palette.slots[55].texture_index
		HStatus.cursor_y = Player.texture_palette.slots[56].texture_index + 128*Player.texture_palette.slots[57].texture_index

		local lbls = HMenu.menus["key_" .. HMode.apply]
		local lbls2 = HMenu.menus["key_" .. HMode.teleport]
		local lbls3 = HMenu.menus["key_" .. HMode.attribute]

		if HStatus.down(HStatus.frozen) then
			lbls[7][7] = "Unfreeze"
			lbls2[7][7] = "Unfreeze"
		else
			lbls[7][7] = "Freeze"
			lbls2[7][7] = "Freeze"
		end

		if HStatus.down(HStatus.undo_active) then
			lbls[5][7] = "Undo"
		else
			lbls[5][7] = "(Can't Undo)"
		end
		if HStatus.down(HStatus.redo_active) then
			lbls[6][7] = "Redo"
		else
			lbls[6][7] = "(Can't Redo)"
		end

		if HApply.down(HApply.align) then
			lbls3[8][7] = "Ignore Adjacent"
		else
			lbls3[8][7] = "Align Adjacent"
		end
		if HApply.down(HApply.transparent) then
			lbls3[9][7] = "Ignore Transparent Sides"
		else
			lbls3[9][7] = "Edit Transparent Sides"
		end
	end,

	down = function(k)
		if HKeys.bitfield == nil then
			debug_print(string.format("HStatus.bitfield in HStatus.down for %u", k), false)
		end
		return hasbit(HStatus.bitfield, k)
	end,
}

HMode = {
	current = -1,
	apply = 0,
	choose = 1,
	attribute = 2,
	teleport = 3,
	panel = 4,
	changed = false,

	update = function()
		local newstate = Player.texture_palette.slots[40].texture_index
		if newstate ~= HMode.current then
			HMode.current = newstate
			HMode.changed = true
		else
			HMode.changed = false
		end
	end,

	is = function(k)
		return k == HMode.current
	end,
}

key_panel_default = {
	{ "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
	{ "kaction", "key_primary", 235, 10, 100, 12, "Select Option" },
	{ "kaction", "key_secondary", 235, 22, 100, 12, "Visual Mode" },
	-- { "kaction", "key_weapon", 235, 38, 100, 12, "Change Script" },
	{ "kaction", "key_move", 235, 50, 100, 12, "Move Cursor" },
	-- { "kaction", "key_mic_primary", 475, 10, 100, 12, "Cycle Textures" },
	{ "kaction", "key_mic_secondary", 475, 22, 100, 12, "Revert Changes" },
	{ "kaction", "key_mic_weapon", 475, 38, 100, 12, "Change Type" },
	-- { "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Next Type" },
	{ "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
	{ "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
	-- { "klabel", "key_weapon", 180, 38, 50, 12, "Prev / Next Weapon" },
	{ "klabel", "key_move", 180, 50, 50, 12, "Look / Move" },
	{ "kmod", "key_mic_any", 380, 4, 44, 64, nil },
	{ "klabel", "key_mic_any", 350, 30, 50, 12, "Aux +" },
	-- { "klabel", "key_mic_primary", 400, 10, 70, 12, "Trigger 1" },
	{ "klabel", "key_mic_secondary", 400, 22, 70, 12, "Trigger 2" },
	{ "klabel", "key_mic_weapon", 400, 38, 70, 12, "Change Weapon" },
	-- { "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Next Weapon" },
	{ "ktab", nil, 20, 4, 130, 16, "Edit Switch / Panel" },
	{ "ktab", "key_mic", 20, 20, 130, 16, "Choose Texture" },
	{ "ktab", "key_action", 20, 36, 130, 16, "Options" },
	{ "ktab", "key_map", 20, 52, 130, 16, "Teleport" },
}

HMenu = {
	menus = {
		[HMode.attribute] = {
			{ "bg", nil, 20, 80, 600, 330, nil },
			{ "checkbox", "apply_tex", 30, 85, 170, 20, "Apply texture" },
			{ "checkbox", "apply_align", 30, 105, 170, 20, "Align adjacent" },
			{ "checkbox", "apply_edit", 30, 125, 170, 20, "Edit switches & panels" },
			{ "checkbox", "apply_xparent", 30, 145, 170, 20, "Edit transparent sides" },
			{ "checkbox", "decouple_xparent", 30, 165, 170, 20, "Decouple transparent sides" },
			{ "checkbox", "apply_realign", 30, 185, 170, 20, "Realign when retexturing" },
			{ "checkbox", "advanced", 30, 205, 170, 20, "Visual Mode header" },
			{ "label", "nil", 30+5, 225, 40, 20, "Snap:" },
			{ "checkbox", "xgrid", 30, 245, 40, 20, "X" },
			{ "checkbox", "ygrid", 30, 265, 40, 20, "Y" },
			{ "radio", "grid_absolute", 70, 225, 130, 20, "Absolute" },
			{ "radio", "grid_negative", 70, 245, 130, 20, "Northwest (relative)" },
			{ "radio", "grid_center", 70, 265, 130, 20, "Centered (relative)" },
			{ "radio", "grid_positive", 70, 285, 130, 20, "Southeast (relative)" },
			{ "radio", "snap_1", 30, 285, 40, 20, snap_modes[1] },
			{ "radio", "snap_2", 30, 305, 40, 20, snap_modes[2] },
			{ "radio", "snap_3", 30, 325, 40, 20, snap_modes[3] },
			{ "radio", "snap_4", 30, 345, 40, 20, snap_modes[4] },
			{ "radio", "snap_5", 30, 365, 40, 20, snap_modes[5] },
			{ "radio", "snap_6", 30, 385, 40, 20, snap_modes[6] },
			{ "radio", "snap_7", 70, 305, 42, 20, snap_modes[7] },
			{ "radio", "snap_8", 70, 325, 42, 20, snap_modes[8] },
			{ "radio", "snap_9", 70, 345, 42, 20, snap_modes[9] },
			{ "radio", "snap_10", 70, 365, 42, 20, snap_modes[10] },
			{ "radio", "snap_11", 70, 385, 42, 20, snap_modes[11] },
			{ "radio", "snap_12", 112, 305, 42, 20, snap_modes[12] },
			{ "radio", "snap_13", 112, 325, 42, 20, snap_modes[13] },
			{ "radio", "snap_14", 112, 345, 42, 20, snap_modes[14] },
			{ "radio", "snap_15", 112, 365, 42, 20, snap_modes[15] },
			{ "radio", "snap_16", 112, 385, 42, 20, snap_modes[16] },
			{ "radio", "snap_17", 154, 305, 46, 20, snap_modes[17] },
			{ "radio", "snap_18", 154, 325, 46, 20, snap_modes[18] },
			{ "radio", "snap_19", 154, 345, 46, 20, snap_modes[19] },
			{ "radio", "snap_20", 154, 365, 46, 20, snap_modes[20] },
			{ "radio", "snap_21", 154, 385, 46, 20, snap_modes[21] },
			{ "checkbox", "apply_light", 205, 85, 240, 20, "Apply light:" },
			{ "checkbox", "apply_transfer", 215, 250, 250, 20, "Apply transfer mode:" },
			-- { "checkbox", "override_landscape", 340, 250, 125, 20, "Override 'Landscape'" },
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
			{ "radio", "transfer_12", 375, 270, 90, 20, "Rev. horiz." },
			{ "radio", "transfer_13", 375, 290, 90, 20, "Rev. fast horiz." },
			{ "radio", "transfer_14", 375, 310, 90, 20, "Rev. vert." },
			{ "radio", "transfer_15", 375, 330, 90, 20, "Rev. fast vert." },
			{ "radio", "transfer_16", 375, 350, 90, 20, "2x" },
			{ "radio", "transfer_17", 375, 370, 90, 20, "4x" },
			{ "label", nil, 485, 250, 120, 20, "Preview" },
			{ "applypreview", nil, 485, 270, 120, 1, nil },
			{ "applypreview", nil, 485, 270, 40, 2, nil },
		},
		apply_options = {
			{ "acheckbox", "apply_light", 110, 394, 155, 14, "Apply light" },
			{ "acheckbox", "apply_tex_mode", 110, 408, 155, 14, "Apply texture" },
			{ "acheckbox", "apply_align", 110, 422, 155, 14, "Align adjacent" },
			{ "acheckbox", "apply_edit", 110, 436, 155, 14, "Edit switches and panels" },
			{ "acheckbox", "apply_xparent", 110, 450, 155, 14, "Edit transparent sides" },
			{ "acheckbox", "apply_snap", 110, 464, 155, 14, "Snap to grid" },
			{ "applypreview", nil, 20, 394, 84, 1, nil },
			{ "applypreview", nil, 86, 398, 20, 2, nil },
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
			{ "label", nil, 170+5, 170, 150, 20, "Platform" }
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
		},
		["key_" .. HMode.apply] = {
			{ "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
			{ "kaction", "key_primary", 235, 10, 100, 12, "Apply Texture" },
			{ "kaction", "key_secondary", 235, 22, 100, 12, "Sample Light + Texture" },
			{ "kaction", "key_weapon", 235, 38, 100, 12, "Change Light" },
			-- { "kaction", "key_move", 235, 50, 100, 12, "Select Surface" },
			{ "kaction", "key_mic_primary", 475, 10, 100, 12, "Undo" },
			{ "kaction", "key_mic_secondary", 475, 22, 100, 12, "Redo" },
			{ "kaction", "key_mic_prev_weapon", 475, 38, 100, 12, "Freeze" },
			{ "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Jump" },
			{ "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
			{ "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
			{ "klabel", "key_weapon", 180, 38, 50, 12, "Change Weapon" },
			-- { "klabel", "key_move", 180, 50, 50, 12, "Look / Move" },
			{ "kmod", "key_mic_any", 380, 4, 44, 64, nil },
			{ "klabel", "key_mic_any", 350, 30, 50, 12, "Aux +" },
			{ "klabel", "key_mic_primary", 400, 10, 70, 12, "Trigger 1" },
			{ "klabel", "key_mic_secondary", 400, 22, 70, 12, "Trigger 2" },
			{ "klabel", "key_mic_prev_weapon", 400, 38, 70, 12, "Prev Weapon" },
			{ "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Next Weapon" },
			{ "ktab", nil, 20, 4, 130, 16, "Visual Mode" },
			{ "ktab", "key_mic", 20, 20, 130, 16, "Choose Texture" },
			{ "ktab", "key_action", 20, 36, 130, 16, "Options" },
			{ "ktab", "key_map", 20, 52, 130, 16, "Teleport" },
		},
		["key_" .. HMode.teleport] = {
			{ "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
			{ "kaction", "key_primary", 235, 10, 100, 12, "Teleport" },
			{ "kaction", "key_secondary", 235, 22, 100, 12, "Visual Mode" },
			{ "kaction", "key_weapon", 235, 38, 100, 12, "Change Polygon" },
			-- { "kaction", "key_move", 235, 50, 100, 12, "Select Polygon" },
			{ "kaction", "key_mic_primary", 475, 10, 100, 12, "Fast Forward Polygon" },
			{ "kaction", "key_mic_secondary", 475, 22, 100, 12, "Rewind Polygon" },
			{ "kaction", "key_mic_prev_weapon", 475, 38, 100, 12, "Freeze" },
			{ "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Jump" },
			{ "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
			{ "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
			{ "klabel", "key_weapon", 180, 38, 50, 12, "Change Weapon" },
			-- { "klabel", "key_move", 180, 50, 50, 12, "Look / Move" },
			{ "kmod", "key_mic_any", 380, 4, 44, 64, nil },
			{ "klabel", "key_mic_any", 350, 30, 50, 12, "Aux +" },
			{ "klabel", "key_mic_primary", 400, 10, 70, 12, "Trigger 1" },
			{ "klabel", "key_mic_secondary", 400, 22, 70, 12, "Trigger 2" },
			{ "klabel", "key_mic_prev_weapon", 400, 38, 70, 12, "Prev Weapon" },
			{ "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Next Weapon" },
			{ "ktab", "key_map", 20, 4, 130, 16, "Visual Mode" },
			{ "ktab", "key_mic", 20, 20, 130, 16, "Choose Texture" },
			{ "ktab", "key_action", 20, 36, 130, 16, "Options" },
			{ "ktab", nil, 20, 52, 130, 16, "Teleport" },
		},
		["key_" .. HMode.choose] = {
			{ "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
			{ "kaction", "key_primary", 235, 10, 100, 12, "Select Texture" },
			{ "kaction", "key_secondary", 235, 22, 100, 12, "Visual Mode" },
			{ "kaction", "key_weapon", 235, 38, 100, 12, "Change Texture" },
			{ "kaction", "key_move", 235, 50, 100, 12, "Move Cursor" },
			{ "kaction", "key_mic_primary", 475, 10, 100, 12, "Fast Forward Texture" },
			{ "kaction", "key_mic_secondary", 475, 22, 100, 12, "Rewind Texture" },
			{ "kaction", "key_mic_weapon", 475, 38, 100, 12, "Change Collection" },
			-- { "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Next Collection" },
			{ "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
			{ "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
			{ "klabel", "key_weapon", 180, 38, 50, 12, "Change Weapon" },
			{ "klabel", "key_move", 180, 50, 50, 12, "Look / Move" },
			{ "kmod", "key_mic_any", 380, 4, 44, 64, nil },
			{ "klabel", "key_mic_any", 350, 30, 50, 12, "Aux +" },
			{ "klabel", "key_mic_primary", 400, 10, 70, 12, "Trigger 1" },
			{ "klabel", "key_mic_secondary", 400, 22, 70, 12, "Trigger 2" },
			{ "klabel", "key_mic_weapon", 400, 38, 70, 12, "Change Weapon" },
			-- { "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Next Weapon" },
			{ "ktab", "key_mic", 20, 4, 130, 16, "Visual Mode" },
			{ "ktab", nil, 20, 20, 130, 16, "Choose Texture" },
			{ "ktab", "key_action", 20, 36, 130, 16, "Options" },
			{ "ktab", "key_map", 20, 52, 130, 16, "Teleport" },
		},
		["key_" .. HMode.attribute] = {
			{ "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
			{ "kaction", "key_primary", 235, 10, 100, 12, "Select Option" },
			{ "kaction", "key_secondary", 235, 22, 100, 12, "Visual Mode" },
			{ "kaction", "key_weapon", 235, 38, 100, 12, "Change Light" },
			{ "kaction", "key_move", 235, 50, 100, 12, "Move Cursor" },
			{ "kaction", "key_mic_primary", 475, 10, 100, 12, "Default Settings" },
			{ "kaction", "key_mic_secondary", 475, 22, 100, 12, "Revert Changes" },
			{ "kaction", "key_mic_prev_weapon", 475, 38, 100, 12, "Ignore Adjacent" },
			{ "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Edit Transparent Sides" },
			{ "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
			{ "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
			{ "klabel", "key_weapon", 180, 38, 50, 12, "Change Weapon" },
			{ "klabel", "key_move", 180, 50, 50, 12, "Look / Move" },
			{ "kmod", "key_mic_any", 380, 4, 44, 64, nil },
			{ "klabel", "key_mic_any", 350, 30, 50, 12, "Aux +" },
			{ "klabel", "key_mic_primary", 400, 10, 70, 12, "Trigger 1" },
			{ "klabel", "key_mic_secondary", 400, 22, 70, 12, "Trigger 2" },
			{ "klabel", "key_mic_prev_weapon", 400, 38, 70, 12, "Prev Weapon" },
			{ "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Next Weapon" },
			{ "ktab", "key_action", 20, 4, 130, 16, "Visual Mode" },
			{ "ktab", "key_mic", 20, 20, 130, 16, "Choose Texture" },
			{ "ktab", nil, 20, 36, 130, 16, "Options" },
			{ "ktab", "key_map", 20, 52, 130, 16, "Teleport" },
		},
		key_panel_off = key_panel_default,
		key_panel_plain = key_panel_default,
		key_panel_terminal = {
			{ "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
			{ "kaction", "key_primary", 235, 10, 100, 12, "Select Option" },
			{ "kaction", "key_secondary", 235, 22, 100, 12, "Visual Mode" },
			{ "kaction", "key_weapon", 235, 38, 100, 12, "Change Script" },
			{ "kaction", "key_move", 235, 50, 100, 12, "Move Cursor" },
			-- 	{ "kaction", "key_mic_primary", 475, 10, 100, 12, "Cycle Textures" },
			{ "kaction", "key_mic_secondary", 475, 22, 100, 12, "Revert Changes" },
			{ "kaction", "key_mic_weapon", 475, 38, 100, 12, "Change Type" },
			-- 	{ "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Next Type" },
			{ "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
			{ "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
			{ "klabel", "key_weapon", 180, 38, 50, 12, "Change Weapon" },
			{ "klabel", "key_move", 180, 50, 50, 12, "Look / Move" },
			{ "kmod", "key_mic_any", 380, 4, 44, 64, nil },
			{ "klabel", "key_mic_any", 350, 30, 50, 12, "Aux +" },
			-- 	{ "klabel", "key_mic_primary", 400, 10, 70, 12, "Trigger 1" },
			{ "klabel", "key_mic_secondary", 400, 22, 70, 12, "Trigger 2" },
			{ "klabel", "key_mic_weapon", 400, 38, 70, 12, "Change Weapon" },
			-- 	{ "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Next Weapon" },
			{ "ktab", nil, 20, 4, 130, 16, "Edit Switch / Panel" },
			{ "ktab", "key_mic", 20, 20, 130, 16, "Choose Texture" },
			{ "ktab", "key_action", 20, 36, 130, 16, "Options" },
			{ "ktab", "key_map", 20, 52, 130, 16, "Teleport" },
		},
		key_panel_light = {
			{ "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
			{ "kaction", "key_primary", 235, 10, 100, 12, "Select Option" },
			{ "kaction", "key_secondary", 235, 22, 100, 12, "Visual Mode" },
			{ "kaction", "key_weapon", 235, 38, 100, 12, "Change Light" },
			{ "kaction", "key_move", 235, 50, 100, 12, "Move Cursor" },
			-- { "kaction", "key_mic_primary", 475, 10, 100, 12, "Cycle Textures" },
			{ "kaction", "key_mic_secondary", 475, 22, 100, 12, "Revert Changes" },
			{ "kaction", "key_mic_weapon", 475, 38, 100, 12, "Change Type" },
			-- { "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Next Type" },
			{ "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
			{ "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
			{ "klabel", "key_weapon", 180, 38, 50, 12, "Change Weapon" },
			{ "klabel", "key_move", 180, 50, 50, 12, "Look / Move" },
			{ "kmod", "key_mic_any", 380, 4, 44, 64, nil },
			{ "klabel", "key_mic_any", 350, 30, 50, 12, "Aux +" },
			-- { "klabel", "key_mic_primary", 400, 10, 70, 12, "Trigger 1" },
			{ "klabel", "key_mic_secondary", 400, 22, 70, 12, "Trigger 2" },
			{ "klabel", "key_mic_weapon", 400, 38, 70, 12, "Change Weapon" },
			-- { "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Next Weapon" },
			{ "ktab", nil, 20, 4, 130, 16, "Edit Switch / Panel" },
			{ "ktab", "key_mic", 20, 20, 130, 16, "Choose Texture" },
			{ "ktab", "key_action", 20, 36, 130, 16, "Options" },
			{ "ktab", "key_map", 20, 52, 130, 16, "Teleport" },
		},
		key_panel_platform = {
			{ "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
			{ "kaction", "key_primary", 235, 10, 100, 12, "Select Option" },
			{ "kaction", "key_secondary", 235, 22, 100, 12, "Visual Mode" },
			{ "kaction", "key_weapon", 235, 38, 100, 12, "Change Platform" },
			{ "kaction", "key_move", 235, 50, 100, 12, "Move Cursor" },
			-- { "kaction", "key_mic_primary", 475, 10, 100, 12, "Cycle Textures" },
			{ "kaction", "key_mic_secondary", 475, 22, 100, 12, "Revert Changes" },
			{ "kaction", "key_mic_weapon", 475, 38, 100, 12, "Change Type" },
			-- { "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Next Type" },
			{ "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
			{ "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
			{ "klabel", "key_weapon", 180, 38, 50, 12, "Change Weapon" },
			{ "klabel", "key_move", 180, 50, 50, 12, "Look / Move" },
			{ "kmod", "key_mic_any", 380, 4, 44, 64, nil },
			{ "klabel", "key_mic_any", 350, 30, 50, 12, "Aux +" },
			-- { "klabel", "key_mic_primary", 400, 10, 70, 12, "Trigger 1" },
			{ "klabel", "key_mic_secondary", 400, 22, 70, 12, "Trigger 2" },
			{ "klabel", "key_mic_weapon", 400, 38, 70, 12, "Change Weapon" },
			-- { "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Next Weapon" },
			{ "ktab", nil, 20, 4, 130, 16, "Edit Switch / Panel" },
			{ "ktab", "key_mic", 20, 20, 130, 16, "Choose Texture" },
			{ "ktab", "key_action", 20, 36, 130, 16, "Options" },
			{ "ktab", "key_map", 20, 52, 130, 16, "Teleport" },
		},
		key_panel_tag = {
			{ "ktab_bg", nil, 150, 4 + menu_prefs.button_indent, 470, 64 - 2*menu_prefs.button_indent, nil },
			{ "kaction", "key_primary", 235, 10, 100, 12, "Select Option" },
			{ "kaction", "key_secondary", 235, 22, 100, 12, "Visual Mode" },
			{ "kaction", "key_weapon", 235, 38, 100, 12, "Change Tag" },
			{ "kaction", "key_move", 235, 50, 100, 12, "Move Cursor" },
			-- { "kaction", "key_mic_primary", 475, 10, 100, 12, "Cycle Textures" },
			{ "kaction", "key_mic_secondary", 475, 22, 100, 12, "Revert Changes" },
			{ "kaction", "key_mic_weapon", 475, 38, 100, 12, "Change Type" },
			-- { "kaction", "key_mic_next_weapon", 475, 50, 100, 12, "Next Type" },
			{ "klabel", "key_primary", 180, 10, 50, 12, "Trigger 1" },
			{ "klabel", "key_secondary", 180, 22, 50, 12, "Trigger 2" },
			{ "klabel", "key_weapon", 180, 38, 50, 12, "Change Weapon" },
			{ "klabel", "key_move", 180, 50, 50, 12, "Look / Move" },
			{ "kmod", "key_mic_any", 380, 4, 44, 64, nil },
			{ "klabel", "key_mic_any", 350, 30, 50, 12, "Aux +" },
			-- { "klabel", "key_mic_primary", 400, 10, 70, 12, "Trigger 1" },
			{ "klabel", "key_mic_secondary", 400, 22, 70, 12, "Trigger 2" },
			{ "klabel", "key_mic_prev_weapon", 400, 38, 70, 12, "Change Weapon" },
			-- { "klabel", "key_mic_next_weapon", 400, 50, 70, 12, "Next Weapon" },
			{ "ktab", nil, 20, 4, 130, 16, "Edit Switch / Panel" },
			{ "ktab", "key_mic", 20, 20, 130, 16, "Choose Texture" },
			{ "ktab", "key_action", 20, 36, 130, 16, "Options" },
			{ "ktab", "key_map", 20, 52, 130, 16, "Teleport" },
		},
	},

	inited = {},
	draw_menu = function(mode, transparent)
		if not HMenu.inited[mode] then HMenu.init_menu(mode) end
		local u = HGlobals.scale
		local m = HMenu.menus[mode]
		local xp = HGlobals.xoff
		local yp = HGlobals.yoff

		if not transparent then
			Screen.fill_rect(Screen.world_rect.x, Screen.world_rect.y,
			                 Screen.world_rect.width, Screen.world_rect.height,
			                 { 0, 0, 0, 1 })
		end

		for idx, item in ipairs(m) do
			local x = xp + item[3]*u
			local y = yp + item[4]*u
			local w = item[5]*u
			local h = item[6]*u

			if item[1] == "label" then
				HGlobals.fontn:draw_text(item[7],
				                         math.floor(x), math.floor(y + h/2 + HGlobals.fnoff),
				                         colors.menu_label)
			elseif item[1] == "klabel" then
				local fw, fh = HGlobals.fontm:measure_text(item[7])
				local state = HMenu.button_state(item[2])
				HGlobals.fontm:draw_text(item[7],
				                         math.floor(x + w - fw), math.floor(y + h/2 + HGlobals.fmoff),
				                         colors.commands[state].label)
			elseif item[1] == "kaction" then
				local state = HMenu.button_state(item[2])
				HGlobals.fontn:draw_text(item[7],
				                         math.floor(x), math.floor(y + h/2 + HGlobals.fnoff),
				                         colors.commands[state].key)
			elseif item[1] == "kmod" then
				local state = HMenu.button_state(item[2])
				local nm = "bracket"
				if state == "enabled" then
					nm = nm .. "_off"
				elseif state == "disabled" then
					nm = nm .. "_dis"
				elseif state == "active" then
					nm = nm .. "_on"
				end

				local img = imgs[nm]
				if img then
					img:draw(x + w/2 - img.width/2, y + h/2 - img.height/2)
				end
			elseif item[1] == "ktab_bg" then
				Screen.fill_rect(x, y, w, h, colors.ktab.background)
			elseif item[1] == "ktab" then
				local state = "current"
				local label = nil
				if item[2] ~= nil then
					state = HMenu.button_state(item[2])
					if item[2] == "key_action" then
						label = "Action"
						if state == "active" then state = "enabled" end
					elseif item[2] == "key_map" then
						label = "Map"
						if state == "active" then state = "enabled" end
					elseif item[2] == "key_mic" then
						label = "Aux"
					end
				end

				local li = menu_prefs.tab_indent.left
				local ri = menu_prefs.tab_indent.right
				local ti = menu_prefs.tab_indent.top
				local bi = menu_prefs.tab_indent.bottom
				if state == "current" then ri = 0 end
				Screen.fill_rect(x + li*u,
				                 y + ti*u,
				                 w - li*u - ri*u,
				                 h - ti*u - bi*u,
				                 colors.ktab[state].background)
				HGlobals.fontn:draw_text(item[7],
				                         math.floor(x + 35*u),
				                         math.floor(y + h/2 + HGlobals.fnoff),
				                         colors.ktab[state].text)
				if label then
					local fw, fh = HGlobals.fontm:measure_text(label)
					HGlobals.fontm:draw_text(label,
					                         math.floor(x + 30*u - fw),
					                         math.floor(y + h/2 + HGlobals.fmoff),
					                         colors.ktab[state].label)
				end
			elseif item[1] == "tab_bg" then
				Screen.fill_rect(x, y, w, h, colors.tab.background)
			elseif item[1] == "bg" then
				Screen.fill_rect(x, y, w, h, colors.tab.background)
			elseif item[1] == "tab" then
				local state = HMenu.button_state(item[2])

				local li = menu_prefs.tab_indent.left
				local ri = menu_prefs.tab_indent.right
				local ti = menu_prefs.tab_indent.top
				local bi = menu_prefs.tab_indent.bottom
				if state == "active" then ri = 0 end
				Screen.fill_rect(x + li*u,
				                 y + ti*u,
				                 w - li*u - ri*u,
				                 h - ti*u - bi*u,
				                 colors.tab[state].background)
				HGlobals.fontn:draw_text(item[7],
				                         math.floor(x + 7*u),
				                         math.floor(y + h/2 + HGlobals.fnoff),
				                         colors.tab[state].text)
			elseif item[1] == "texture" or item[1] == "atexture" or item[1] == "dtexture" then
				local cc, ct = string.match(item[2], "(%d+)_(%d+)")
				local indent = menu_prefs.texture_preview_indent
				local state = "enabled"

				if item[1] == "texture" then
					state = HMenu.button_state(item[2])
					indent = menu_prefs.texture_choose_indent
				elseif item[1] == "atexture" then
					state = HMenu.button_state(item[2])
					indent = menu_prefs.texture_apply_indent
				end
				local iu = indent * u

				if state == "active" then
					Screen.frame_rect(x - iu,
					                  y - iu,
					                  w + 2*iu,
					                  h + 2*iu,
					                  colors.current_texture,
					                  2*iu)
				end
				local xt = x + iu
				local yt = y + iu
				local wt = w - 2*iu
				local ht = h - 2*iu
				HCollections.draw(cc + 0, ct + 0, xt, yt, wt, ht)
			elseif item[1] == "applypreview" then
				HCollections.preview_current(x, y, w, item[6])
			elseif item[1] == "light" then
				local state = HMenu.button_state(item[2])

				local xt = x + menu_prefs.button_indent*u
				local yt = y + menu_prefs.button_indent*u
				local wt = w - 2*menu_prefs.button_indent*u
				local ht = h - 2*menu_prefs.button_indent*u

				local c = colors.light[state]

				local val = HLights.val(tonumber(string.sub(item[2], 7)))
				local sz = ht - 2*menu_prefs.light_thickness*u
				Screen.fill_rect(xt + wt - ht + menu_prefs.light_thickness*u - 1,
				                 yt + menu_prefs.light_thickness*u,
				                 sz + 1,
				                 sz + 1,
				                 { val, val, val, 1 })
				Screen.frame_rect(xt + wt - ht, yt, ht, ht, c.frame, menu_prefs.light_thickness*u)

				local fw, fh = HGlobals.fontm:measure_text(item[7])
				local yh = yt + ht/2 - fh/2
				local xh = xt + wt - ht - 2*u - fw
				HGlobals.fontm:draw_text(item[7], xh, yh, c.text)

			elseif HMenu.clickable(item[1]) then
				local state = HMenu.button_state(item[2])
				HMenu.draw_button_background(item, state)

				local xo = 7
				if item[1] == "checkbox" or item[1] == "acheckbox" or item[1] == "radio" then
					xo = 17
				elseif item[1] == "light" then
					local fw, fh = HGlobals.fontn:measure_text(item[7])
					xo = item[5] - 7 - fw/u
				elseif item[1] == "dbutton" then
					local fw, fh = HGlobals.fontn:measure_text(item[7])
					xo = (w/u - fw/u)/2
				end
				HMenu.draw_button_text(item, state, xo)

				if item[1] == "checkbox" or item[1] == "acheckbox" or item[1] == "radio" then
					local nm = "dcheck"
					if item[1] == "radio" then
						nm = "dradio"
					elseif item[1] == "acheckbox" then
						nm = "fcheck"
					end
					if state == "enabled" then
						nm = nm .. "_off"
					elseif state == "disabled" then
						nm = nm .. "_dis"
					elseif state == "active" then
						nm = nm .. "_on"
					end

					local img = imgs[nm]
					if img then
						local x = HGlobals.xoff + item[3]*u + menu_prefs.button_indent*u
						local y = HGlobals.yoff + item[4]*u + menu_prefs.button_indent*u
						local h = item[6]*u - 2*menu_prefs.button_indent*u
						img:draw(x + 4*u, y + h/2 - img.height/2)
					end
				elseif item[1] == "light" then
					local val = HLights.val(tonumber(string.sub(item[2], 7)))
					Screen.fill_rect(x + 2*u, y + 2*u, h - 4*u, h - 4*u, { val, val, val, 1 })
				end
			end
		end
	end,

	button_state = function(name)
		local state = "enabled"

		if name == "enabled" then
			state = "enabled"
		elseif name == "active" then
			state = "active"
		elseif name == "disabled" then
			state = "disabled"
		elseif name == "apply_tex" then
			if HApply.down(HApply.use_texture) then state = "active" end
		elseif name == "apply_tex_mode" then
			if HApply.down(HApply.use_texture) or HApply.use_transfer then state = "active" end
		elseif name == "apply_light" then
			if HApply.down(HApply.use_light) then state = "active" end
		elseif name == "apply_align" then
			if HApply.down(HApply.align) then state = "active" end
		elseif name == "apply_xparent" then
			if HApply.down(HApply.transparent) then state = "active" end
		elseif name == "decouple_xparent" then
			if Level.stash["decouple"] == "TRUE" then state = "active" end
		elseif name == "apply_edit" then
			if HApply.down(HApply.edit_panels) then state = "active" end
		elseif name == "apply_realign" then
			if HApply.realign then state = "active" end
		elseif name == "advanced" then
			if not HStatus.down(HStatus.advanced_active) then state = "active" end
		elseif name == "xgrid" then
			if HApply.snap_x then state = "active" end
		elseif name == "ygrid" then
			if HApply.snap_y then state = "active" end
		elseif name == "apply_snap" then
			if HApply.snap_x or HApply.snap_y then state = "active" end
		elseif name == "grid_absolute" then
			if HApply.current_snap_mode == 0 then state = "active" end
		elseif name == "grid_negative" then
			if HApply.current_snap_mode == 1 then state = "active" end
		elseif name == "grid_center" then
			if HApply.current_snap_mode == 2 then state = "active" end
		elseif name == "grid_positive" then
			if HApply.current_snap_mode == 3 then state = "active" end
		elseif string.sub(name, 1, 5) == "snap_" then
			local mode = tonumber(string.sub(name, 6))
			if HApply.current_snap == mode then state = "active" end
		elseif name == "apply_transfer" then
			if HApply.use_transfer == 1 then state = "active" end
		elseif string.sub(name, 1, 9) == "transfer_" then
			local mode = tonumber(string.sub(name, 10))
			if HApply.current_transfer == mode then state = "active" end
			if HCollections.current_collection == 0 and mode ~= 5 then state = "disabled" end
			if HApply.use_transfer == 0 and not HApply.down(HApply.use_texture) then state = "disabled" end
		elseif string.sub(name, 1, 6) == "light_" then
			local mode = tonumber(string.sub(name, 7))
			if HApply.current_light == mode then state = "active" end
		elseif string.sub(name, 1, 5) == "coll_" then
			local mode = tonumber(string.sub(name, 6))
			if HCollections.current_collection == mode then state = "active" end
		elseif string.sub(name, 1, 7) == "choose_" then -- textures
			local cc, ct = string.match(name, "(%d+)_(%d+)")
			if tonumber(cc) == HCollections.current_coll() and tonumber(ct) == Player.texture_palette.slots[cc].texture_index then
				state = "active"
			end
		elseif string.sub(name, 1, 6) == "pperm_" then
			local mode = tonumber(string.sub(name, 7))
			if HPanel.permutation == mode then state = "active" end
		elseif string.sub(name, 1, 6) == "ptype_" then
			local mode = tonumber(string.sub(name, 7))
			if not HPanel.valid_class(mode) then state = "disabled" end
			if mode == 0 then state = "enabled" end
			if mode == HPanel.current_class then state = "active" end
		elseif name == "panel_light" then
			if HPanel.option_set(1) then state = "active" end
			if not HPanel.valid_option(1) then state = "disabled" end
		elseif name == "panel_weapon" then
			if HPanel.option_set(2) then state = "active" end
			if not HPanel.valid_option(2) then state = "disabled" end
		elseif name == "panel_repair" then
			if HPanel.option_set(3) then state = "active" end
			if not HPanel.valid_option(3) then state = "disabled" end
		elseif name == "panel_active" then
			if HPanel.option_set(4) then state = "active" end
			if not HPanel.valid_option(4) then state = "disabled" end
		elseif string.sub(name, 1, 8) == "key_mic_" then
			state = HKeys.button_state(string.sub(name, 9), true)
		elseif string.sub(name, 1, 4) == "key_" then
			state = HKeys.button_state(string.sub(name, 5), false)
		end

		return state
	end,

	draw_button_background = function(item, state)
		local u = HGlobals.scale
		local x = HGlobals.xoff + item[3]*u + menu_prefs.button_indent*u
		local y = HGlobals.yoff + item[4]*u + menu_prefs.button_indent*u
		local w = item[5]*u - 2*menu_prefs.button_indent*u
		local h = item[6]*u - 2*menu_prefs.button_indent*u
		local th = menu_prefs.button_highlight_thickness*u
		local ts = menu_prefs.button_shadow_thickness*u
		local c = colors.button[state]
		if item[1] == "acheckbox" then c = colors.apply[state] end

		Screen.fill_rect(x,           y,           w,       h,            c.background)
		Screen.fill_rect(x,           y,           w,       th,           c.highlight)
		Screen.fill_rect(x,           y + th,      th,      h - th,       c.highlight)
		Screen.fill_rect(x + th,      y + h - ts,  w - th,  ts,           c.shadow)
		Screen.fill_rect(x + w - ts,  y + th,      ts,      h - th - ts,  c.shadow)
	end,

	draw_button_text = function(item, state, xoff)
		local u = HGlobals.scale
		local x = HGlobals.xoff + item[3]*u + menu_prefs.button_indent*u
		local y = HGlobals.yoff + item[4]*u + menu_prefs.button_indent*u
		local h = item[6]*u - 2*menu_prefs.button_indent*u
		local c = colors.button[state]
		if item[1] == "acheckbox" then c = colors.apply[state] end

		HGlobals.fontn:draw_text(item[7],
		                         math.floor(x + xoff*u),
		                         math.floor(y + h/2 + HGlobals.fnoff),
		                         c.text)
	end,

	init_menu = function(mode)
		local menu = HMenu.menus[mode]
		if mode == HMode.attribute then
			if HCounts.num_lights > 0 then
				for i = 1,math.min(HCounts.num_lights, MAX_LIGHTS) do
					local l = i - 1
					local yoff = (l % 7) * 20
					local xoff = math.floor(l / 7) * 30
					local w = 30
					if xoff == 0 then
						w = w - 13
					else
						xoff = xoff - 13
					end
					table.insert(menu, 14 + l,
						{ "light", "light_" .. l, 215 + xoff, 105 + yoff, w, 20, tostring(l) })
				end
				HMenu.inited[mode] = true
			end
		elseif mode == "panel_light" then
			if HCounts.num_lights > 0 then
				for i = 1,math.min(HCounts.num_lights, MAX_LIGHTS) do
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
				HMenu.inited[mode] = true
			end
		elseif mode == "panel_terminal" then
			if HCounts.num_scripts > 0 then
				for i = 1,math.min(HCounts.num_scripts, 90) do
					local l = i - 1
					local yoff = (l % 10) * 20
					local xoff = math.floor(l / 10) * 49
					table.insert(menu,
						{ "radio", "pperm_" .. l, 170 + xoff, 150 + yoff, 49, 20, tostring(l) })
				end
				HMenu.inited[mode] = true
			end
		elseif mode == "panel_tag" then
			if HCounts.num_tags > 0 then
				for i = 1,math.min(HCounts.num_tags, 90) do
					local l = i - 1
					local yoff = (l % 10) * 20
					local xoff = math.floor(l / 10) * 49
					table.insert(menu,
						{ "radio", "pperm_" .. l, 170 + xoff, 190 + yoff, 49, 20, tostring(l) })
				end
				HMenu.inited[mode] = true
			end
		elseif mode == "panel_platform" then
			if HCounts.num_platforms > 0 then
				for i = 1,math.min(HCounts.num_platforms, 1024) do
					local l = i - 1
					local yoff = (l % 20) * 10
					local xoff = math.floor(l / 20) * 40
					l = HPlatforms.indexes[l]
					table.insert(menu,
						{ "radio", "pperm_" .. l, 170 + xoff, 190 + yoff, 39, 10, tostring(l) })
				end
				HMenu.inited[mode] = true
			end
		else
			HMenu.inited[mode] = true
		end
	end,

	clickable = function(item_type)
		return item_type == "button"
		    or item_type == "checkbox"
		    or item_type == "radio"
		    or item_type == "texture"
		    or item_type == "light"
		    or item_type == "dbutton"
		    or item_type == "acheckbox"
		    or item_type == "tab"
	end
}

HChoose = {
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

HCollections = {
	inited = false,
	current_collection = 0,
	current_texture = 0,
	current_landscape_collection = 0,
	current_type = nil,
	wall_collections = {},
	landscape_offsets = {},
	landscape_textures = {},
	all_shapes = {},
	names = {"Coll 0",  "Coll 1",  "Coll 2",  "Coll 3",  "Coll 4",  "Coll 5",  "Coll 6",  "Coll 7",
	         "Coll 8",  "Coll 9",  "Coll 10", "Coll 11", "Coll 12", "Coll 13", "Coll 14", "Coll 15",
	         "Coll 16", "Coll 17", "Coll 18", "Coll 19", "Coll 20", "Coll 21", "Coll 22", "Coll 23",
	         "Coll 24", "Coll 25", "Coll 26", "Coll 27", "Coll 28", "Coll 29", "Coll 30", "Coll 31"},

	init = function()
		for k,v in danger_pairs(collection_names) do
			HCollections.names[k + 1] = v
		end

		local landscape = false
		local landscape_offset = 0
		for i = 0,31 do
			local collection = Player.texture_palette.slots[i].collection
			if collection == 0 then
				if landscape then break end
				landscape = true
			else
				local bct = Collections[collection].bitmap_count
				if landscape then
					HCollections.landscape_offsets[collection] = landscape_offset
					landscape_offset = landscape_offset + bct
				end
				HCollections.all_shapes[collection] = {}
				local ttype = TextureTypes["wall"]
				if landscape then
					ttype = TextureTypes["landscape"]
				else
					table.insert(HCollections.wall_collections, collection)
				end
				for j = 0,bct-1 do
					HCollections.all_shapes[collection][j] = Shapes.new{collection = Collections[collection], texture_index = j, type = ttype}
					if landscape then
						table.insert(HCollections.landscape_textures, { collection, j })
					end
				end
			end
		end


		local num_walls = #HCollections.wall_collections
		local num_land = #HCollections.landscape_textures

		local menu_colls = {}
		for _,cnum in danger_pairs(HCollections.wall_collections) do
			local bct = Collections[cnum].bitmap_count
			local rows, cols = HChoose.gridsize(bct)
			table.insert(menu_colls, { cnum = cnum, bct = bct, rows = rows, cols = cols, xscale = 1 })
		end
		if num_land > 0 then
			local rows, cols = HChoose.widegridsize(num_land)
			table.insert(menu_colls, { cnum = 0, bct = num_land, rows = rows, cols = cols, xscale = 2 })
		end

		-- set up apply-mode previews
		for i = 1,#menu_colls do
			local preview = {}
			local cinfo = menu_colls[i]
			local cnum, bct, rows, cols, xscale = cinfo.cnum, cinfo.bct, cinfo.rows, cinfo.cols, cinfo.xscale
			if preview_collection_when_applying then
				local w = 168
				local h = 84
				local tsize = math.min(w / (cols * xscale), h / rows)
				local x = 620 - (tsize * cols * xscale)
				local y = 480 - 88/2 - (tsize * rows)/2
				for j = 1,bct do
					local col = (j - 1) % cols
					local row = math.floor((j - 1) / cols)
					local xt = x + (tsize * col * xscale)
					local yt = y + (tsize * row)

					local cc = cnum
					local ct = j - 1
					if cnum == 0 then
						cc = HCollections.landscape_textures[j][1]
						ct = HCollections.landscape_textures[j][2]
					end
					table.insert(preview,
					             { "atexture", string.format("choose_%s_%s", cc, ct),
					               xt, yt, tsize * xscale, tsize, string.format("%s, %s", cc, ct) }
					)
				end
			end
			HMenu.menus["preview_" .. cnum] = preview
		end

		-- set up collection buttons
		local cbuttons = {}
		if #menu_colls > 0 then
			local n = #menu_colls
			local w = 600 / n

			local x = 20
			local y = 380
			for i = 1,n do
				local cinfo = menu_colls[i]
				local cnum = cinfo.cnum
				local cname = HCollections.names[cnum + 1]
				table.insert(cbuttons,
					{ "dbutton", "coll_" .. cnum, x, y, w, 20, cname })

				-- collection preview
				if preview_all_collections then
					local xx = x + menu_prefs.button_indent
					local yy = y + 20 + menu_prefs.button_indent
					local ww = w - 2*menu_prefs.button_indent
					local hh = 75 - 2*menu_prefs.button_indent

					local bct, rows, cols, xscale = cinfo.bct, cinfo.rows, cinfo.cols, cinfo.xscale
					local tsize = math.min(ww / (cols * xscale), hh / rows)
					xx = xx + (ww - (tsize * cols * xscale))/2

					for j = 1,bct do
						local col = (j - 1) % cols
						local row = math.floor((j - 1) / cols)
						local xt = xx + (tsize * col * xscale)
						local yt = yy + (tsize * row)

						local cc = cnum
						local ct = j - 1
						if cnum == 0 then
							cc = HCollections.landscape_textures[j][1]
							ct = HCollections.landscape_textures[j][2]
						end
						table.insert(cbuttons,
						             { "dtexture", "display_" .. cc .. "_" .. ct, 
						               xt, yt, tsize * xscale, tsize, cc .. ", " .. ct }
						)
					end
				end

				x = x + w
			end
		end

		-- set up grid
		for _,cinfo in ipairs(menu_colls) do
			local cnum, bct, rows, cols, xscale = cinfo.cnum, cinfo.bct, cinfo.rows, cinfo.cols, cinfo.xscale

			local buttons = {}
			local tsize = math.min(600 / (cols * xscale), 300 / rows)

			for i = 1,bct do
				local col = (i - 1) % cols
				local row = math.floor((i - 1) / cols)
				local x = 20 + (tsize * col * xscale) + (600 - (tsize * cols * xscale))/2
				local y = 80 + (tsize * row) + (300 - (tsize * rows))/2

				local cc = cnum
				local ct = i - 1
				if cnum == 0 then
					cc = HCollections.landscape_textures[i][1]
					ct = HCollections.landscape_textures[i][2]
				end
				table.insert(buttons,
				             { "texture", string.format("choose_%s_%s", cc, ct),
				               x, y, tsize * xscale, tsize, string.format("%s, %s", cc, ct) }
				)
			end
			for _,v in ipairs(cbuttons) do
				table.insert(buttons, v)
			end

			HMenu.menus["choose_" .. cnum] = buttons
		end

		HCollections.inited = true
	end,

	update = function()
		local slots = Player.texture_palette.slots
		HCollections.current_collection = slots[32].collection
		HCollections.current_texture = slots[32].texture_index
		HCollections.current_type = slots[HCollections.current_collection].type
		HCollections.current_landscape_collection = slots[0].texture_index

		if not HCollections.inited then HCollections.init() end
	end,

	current_coll = function()
		local coll = HCollections.current_collection
		if coll == 0 then
			coll = HCollections.current_landscape_collection
		end
		return coll
	end,

	shape = function(coll, tex)
		if coll == nil then
			coll = HCollections.current_coll()
		end
		if coll == 0 then
			coll = HCollections.current_landscape_collection
		end
		if tex == nil then
			tex = Player.texture_palette.slots[coll].texture_index
		end
		return HCollections.all_shapes[coll][tex]
	end,

	is_landscape = function(coll)
		if coll == nil then
			coll = HCollections.current_coll()
		end
		if coll == 0 then
			coll = HCollections.current_landscape_collection
		end
		return Player.texture_palette.slots[coll].type.mnemonic == "landscape"
	end,

	predraw = function(coll, tex, w, h)
		local xb, yb = 0, 0
		local shp = HCollections.shape(coll, tex) 
		if not shp then return nil, 0, 0 end
		if HCollections.is_landscape(coll) then
			local sw = shp.unscaled_width
			local sh = shp.unscaled_height
			local aspect = sw / sh
			local scale = math.max(w / sw, h / sh)

			-- work around deep voodoo in landscape rendering
			local nh = sh / (aspect * 540/1024)
			shp:rescale(sw * scale, nh * scale)

			local xoff = (shp.width - w)/2
			local yoff = (shp.height - h)/2
			shp.crop_rect.x = math.max(0, xoff)
			shp.crop_rect.y = math.max(0, yoff)
			shp.crop_rect.width = math.min(w, shp.width)
			shp.crop_rect.height = math.min(h, shp.height)
			xb = math.max(0, -xoff)
			yb = math.max(0, -yoff)
		else
			shp:rescale(w, h)
		end
		return shp, xb, yb
	end,

	draw = function(coll, tex, x, y, w, h)
		local shp, xoff, yoff = HCollections.predraw(coll, tex, w, h)
		if shp then shp:draw(x + xoff, y + yoff) end
	end,

	preview_current = function(x, y, size, mode)
		if (mode == 1) and (not HApply.down(HApply.use_texture)) then return end
		if (mode == 2) and      HApply.down(HApply.use_texture)  then return end

		local pref = menu_prefs.preview.apply
		if HMode.is(HMode.attribute) then pref = menu_prefs.preview.attribute end
		local u = HGlobals.scale
		local oldx = Screen.clip_rect.x
		local oldy = Screen.clip_rect.y
		local oldw = Screen.clip_rect.width
		local oldh = Screen.clip_rect.height
		Screen.clip_rect.x = x
		Screen.clip_rect.y = y
		Screen.clip_rect.width = size
		Screen.clip_rect.height = size

		local coll = HCollections.current_coll()
		local tex = Player.texture_palette.slots[coll].texture_index

		if HApply.down(HApply.use_texture) or HApply.use_transfer == 1 then
			if HApply.current_transfer == 4 then
				local xoff = math.random() * math.max(0, img_static.width - size)
				local yoff = math.random() * math.max(0, img_static.height - size)
				img_static:draw(x - xoff, y - yoff)
			else
				local xoff, yoff, sxmult, symult = HCollections.calc_transfer(HApply.current_transfer)
				xoff = xoff * size
				yoff = yoff * size
				local sx = size * sxmult
				local sy = size * symult

				local shp, shpx, shpy = HCollections.predraw(coll, tex, sx, sy)
				local xp = x + xoff + shpx
				local yp = y + yoff + shpy

				local extrax = { { true, xp }, { xoff > 0, xp - sx }, { (xoff + sx) < size, xp + sx } }
				local extray = { { true, yp }, { yoff > 0, yp - sy }, { (yoff + sy) < size, yp + sy } }
				for _,xv in ipairs(extrax) do
					if xv[1] then
						for _,yv in ipairs(extray) do
							if yv[1] then
								if shp then shp:draw(xv[2], yv[2]) end
							end
						end
					end
				end

				if HApply.down(HApply.use_light) and HApply.current_transfer ~= 5 then
					if HApply.current_light < MAX_LIGHTS then
						local val = HLights.adj(HApply.current_light)
						Screen.fill_rect(x, y, size, size, { 0, 0, 0, 1 - val })
					end
				end

				if pref.snap_grid > 0 and (HApply.snap_x or HApply.snap_y) then
					local border = u * pref.snap_grid
					Screen.frame_rect(x, y, size, size, colors.snap_grid, border)
					local grids = snap_denominators[HApply.current_snap]
					for i = 1,grids-1 do
						local off = size * i / grids
						if HApply.snap_x then
							Screen.fill_rect(x + off - border/2, y + border,
							                 border, size - 2*border, colors.snap_grid)
						end
						if HApply.snap_y then
							Screen.fill_rect(x + border, y + off - border/2,
							                 size - 2*border, border, colors.snap_grid)
						end
					end
				end
			end
		elseif HApply.down(HApply.use_light) then
			local val = HLights.val(HApply.current_light)
			local border = u * pref.light_border
			Screen.fill_rect(x, y, size, size, colors.light.enabled.frame)
			Screen.fill_rect(x + border, y + border,
			                 size - 2*border, size - 2*border,
			                 { val, val, val, 1 })
		end

		Screen.clip_rect.x = oldx
		Screen.clip_rect.y = oldy
		Screen.clip_rect.width = oldw
		Screen.clip_rect.height = oldh
	end,

	calc_transfer = function(ttype)
		local x = 0
		local y = 0
		local sx = 1
		local sy = 1
		if ttype == 1 or ttype == 2 or ttype == 3 then
			local phase = Game.ticks
			if ttype == 3 then phase = phase * 15 end
			phase = bit32.band(phase, 63)
			if phase >= 32 then
				phase = 48 - phase
			else
				phase = phase - 16
			end
			if ttype == 1 then
				sx = 1 - (phase - 8) / 1024
				x = (phase - 8) / 2
				sy = sx
				y = x
			else
				sx = 1 + (phase - 8) / 1024
				sy = 1 - (phase - 8) / 1024
				y = (phase - 8) / 2
			end
		elseif ttype > 5 and ttype < 16 then
			local phase = Game.ticks
			if ttype % 2 == 1 then phase = phase * 2 end
			if ttype >= 12 then phase = phase * -1 end
			if ttype == 6 or ttype == 7 or ttype == 12 or ttype == 13 then
				x = bit32.band(phase * 4, 1023)
			elseif ttype == 8 or ttype == 9 or ttype == 14 or ttype == 15 then
				y = bit32.band(phase * 4, 1023)
			elseif ttype == 10 or ttype == 11 then
				local alt = phase % 5120
				phase = phase % 3072
				x = (math.cos(HCollections.norm_angle(alt)) +
				     math.cos(HCollections.norm_angle(2*alt))/2 +
				     math.cos(HCollections.norm_angle(5*alt))/2)*256
				y = (math.sin(HCollections.norm_angle(phase)) +
				     math.sin(HCollections.norm_angle(2*phase))/2 +
				     math.sin(HCollections.norm_angle(3*phase))/2)*256
					 while x > 1024 do x = x - 1024 end
				while x < 0 do x = x + 1024 end
				while y < 0 do y = y + 1024 end
			end
		end
		return x/1024, y/1024, sx, sy
	end,

	norm_angle = function(angle)
		return bit32.band(angle, 511) * 2*math.pi / 512
	end,
}


HCounts = {
	num_lights = 0,
	num_polys = 0,
	num_platforms = 0,
	num_tags = 0,
	num_scripts = 0,

	update = function()
		local ct = Player.texture_palette.slots[33].texture_index + 128*Player.texture_palette.slots[34].texture_index
		local turn = (Game.ticks - 1) % 5
		if     turn == 0 then HCounts.num_lights = ct
		elseif turn == 1 then HCounts.num_polys = ct
		elseif turn == 2 then HCounts.num_platforms = ct
		elseif turn == 3 then HCounts.num_tags = ct
		elseif turn == 4 then HCounts.num_scripts = ct
		end
	end,
}


HLights = {
	inited = false,
	intensities = {},

	update = function()
		if HCounts.num_lights < 1 then return end
		for i = 1,math.min(HCounts.num_lights, MAX_LIGHTS) do
			local slot = Player.texture_palette.slots[199 + i]
			if (slot ~= nil) and (slot.texture_index ~= nil) then
				HLights.intensities[i] = slot.texture_index / 128
			else
				HLights.intensities[i] = 0
			end
		end
		HLights.inited = true
	end,

	val = function(idx)
		if not HLights.inited then return 1 end
		return HLights.intensities[idx + 1]
	end,

	adj = function(idx)
		if not HLights.inited then return 1 end
		return 0.5 + HLights.intensities[idx + 1]/2
	end,
}

HPlatforms = {
	indexes = {},

	update = function()
		if HCounts.num_platforms < 1 then return end
		local poly = Player.texture_palette.slots[35].texture_index + 128*Player.texture_palette.slots[36].texture_index
		local turn = (Game.ticks - 1) % HCounts.num_platforms
		HPlatforms.indexes[turn] = poly
	end,
}

HTeleport = {
	poly = 0,

	update = function()
		HTeleport.poly = Player.texture_palette.slots[37].texture_index + 128*Player.texture_palette.slots[38].texture_index
	end,
}

HPanel = {
	bitfield_class = 0,
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
	current_class = 0,
	bitfield_option = 0,
	light_dependent = 1,
	weapons_only = 2,
	repair = 3,
	active = 4,
	permutation = 0,

	update = function()
		HPanel.bitfield_class = Player.texture_palette.slots[48].texture_index + 128*Player.texture_palette.slots[49].texture_index
		HPanel.current_class = Player.texture_palette.slots[50].texture_index
		HPanel.bitfield_option = Player.texture_palette.slots[51].texture_index
		HPanel.permutation = Player.texture_palette.slots[52].texture_index + 128*Player.texture_palette.slots[53].texture_index
	end,

	valid_class = function(k)
		if HPanel.bitfield_class == nil then
			debug_print(string.format("HPanel.bitfield_class in HPanel.valid_class for %u", k), false)
		end
		return hasbit(HPanel.bitfield_class, k)
	end,

	option_set = function(k)
		if HPanel.bitfield_option == nil then
			debug_print(string.format("HPanel.bitfield_option in HPanel.option_set for %u", k), false)
		end
		return hasbit(HPanel.bitfield_option, k)
	end,

	valid_option = function(k)
		if k == HPanel.light_dependent then
			return true
		elseif k == HPanel.weapons_only or k == HPanel.repair then
			return HPanel.current_class == HPanel.light_switch
			    or HPanel.current_class == HPanel.platform_switch
			    or HPanel.current_class == HPanel.tag_switch
			    or HPanel.current_class == HPanel.chip
			    or HPanel.current_class == HPanel.wires
		elseif k == HPanel.active then
			return HPanel.current_class == HPanel.tag_switch
			    or HPanel.current_class == HPanel.chip
			    or HPanel.current_class == HPanel.wires
		end
		return false
	end,

	menu_name = function()
		local current_class = HPanel.current_class
		if current_class == HPanel.oxygen or
		   current_class == HPanel.x1 or
		   current_class == HPanel.x2 or
		   current_class == HPanel.x3 or
		   current_class == HPanel.save then
			return "panel_plain"
		elseif current_class == HPanel.terminal then
			return "panel_terminal"
		elseif current_class == HPanel.light_switch then
			return "panel_light"
		elseif current_class == HPanel.platform_switch then
			return "panel_platform"
		elseif current_class == HPanel.tag_switch or
		       current_class == HPanel.chip or
		       current_class == HPanel.wires then
			return "panel_tag"
		end
		return "panel_off"
	end,
}
