--- STEAMODDED HEADER
--- MOD_NAME: Ionized
--- MOD_ID: Ionized
--- MOD_AUTHOR: [NewtTheFish]
--- MOD_DESCRIPTION: Adds the Ionized edition.

----------------------------------------------
------------MOD CODE -------------------------

local generate_card_ui_ref = generate_card_ui
function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end)
	local original_full_UI_table = full_UI_table
	local original_main_end = main_end
	local first_pass = nil
	if not full_UI_table then
		first_pass = true
		full_UI_table = {
			main = {},
			info = {},
			type = {},
			name = nil,
			badges = badges or {}
		}
	end

	local desc_nodes = (not full_UI_table.name and full_UI_table.main) or full_UI_table.info
	local name_override = nil
	local info_queue = {}

	local loc_vars = nil

	if not (card_type == 'Locked') and not hide_desc and not (specific_vars and specific_vars.debuffed) then
		local key = _c.key
		local center_obj = SMODS.Tarots[key] or SMODS.Planets[key] or SMODS.Spectrals[key] or SMODS.Vouchers[key]
		if center_obj and center_obj.loc_def and type(center_obj.loc_def) == 'function' then
			local o, m = center_obj.loc_def(_c, info_queue)
			if o then loc_vars = o end
			if m then main_end = m end
		end
		local joker_obj = SMODS.Jokers[key]
		if joker_obj and joker_obj.tooltip and type(joker_obj.tooltip) == 'function' then
			joker_obj.tooltip(_c, info_queue)
		end
	end

    if first_pass and not (_c.set == 'Edition') and badges then
        for k, v in ipairs(badges) do
            if v == 'ionized' then info_queue[#info_queue+1] = {key = 'e_ionized', set = 'Other'} end

            if v == 'gold_seal' then info_queue[#info_queue+1] = {key = 'gold_seal', set = 'Other'} end
            if v == 'blue_seal' then info_queue[#info_queue+1] = {key = 'blue_seal', set = 'Other'} end
            if v == 'red_seal' then info_queue[#info_queue+1] = {key = 'red_seal', set = 'Other'} end
            if v == 'purple_seal' then info_queue[#info_queue+1] = {key = 'purple_seal', set = 'Other'} end
        end
    end

	if loc_vars or next(info_queue) then
		if full_UI_table.name then
			full_UI_table.info[#full_UI_table.info + 1] = {}
			desc_nodes = full_UI_table.info[#full_UI_table.info]
		end
		if not full_UI_table.name then
			if specific_vars and specific_vars.no_name then
				full_UI_table.name = true
			elseif card_type == 'Locked' then
				full_UI_table.name = localize { type = 'name', set = 'Other', key = 'locked', nodes = {} }
			elseif card_type == 'Undiscovered' then
				full_UI_table.name = localize { type = 'name', set = 'Other', key = 'undiscovered_' .. (string.lower(_c.set)), name_nodes = {} }
			elseif specific_vars and (card_type == 'Default' or card_type == 'Enhanced') then
				if (_c.name == 'Stone Card') then full_UI_table.name = true end
				if (specific_vars.playing_card and (_c.name ~= 'Stone Card')) then
					full_UI_table.name = {}
					localize { type = 'other', key = 'playing_card', set = 'Other', nodes = full_UI_table.name, vars = { localize(specific_vars.value, 'ranks'), localize(specific_vars.suit, 'suits_plural'), colours = { specific_vars.colour } } }
					full_UI_table.name = full_UI_table.name[1]
				end
			elseif card_type == 'Booster' then

			else
				full_UI_table.name = localize { type = 'name', set = _c.set, key = _c.key, nodes = full_UI_table.name }
			end
			full_UI_table.card_type = card_type or _c.set
		end
		if main_start then
			desc_nodes[#desc_nodes + 1] = main_start
		end
		if loc_vars then
			localize { type = 'descriptions', key = _c.key, set = _c.set, nodes = desc_nodes, vars = loc_vars }
			if not ((specific_vars and not specific_vars.sticker) and (card_type == 'Default' or card_type == 'Enhanced')) then
				if desc_nodes == full_UI_table.main and not full_UI_table.name then
					localize { type = 'name', key = _c.key, set = _c.set, nodes = full_UI_table.name }
					if not full_UI_table.name then full_UI_table.name = {} end
				elseif desc_nodes ~= full_UI_table.main then
					desc_nodes.name = localize { type = 'name_text', key = name_override or _c.key, set = name_override and 'Other' or _c.set }
				end
			end
		end
        if _c.set == 'Other' then
            localize{type = 'other', key = _c.key, nodes = desc_nodes, vars = specific_vars}
		end

		if main_end then
			desc_nodes[#desc_nodes + 1] = main_end
		end

		for _, v in ipairs(info_queue) do
			generate_card_ui(v, full_UI_table)
		end
		return full_UI_table
	end
	return generate_card_ui_ref(_c, original_full_UI_table, specific_vars, card_type, badges, hide_desc, main_start,
		original_main_end)
end

-- generic use consumeable
local use_consumeable_ref = Card.use_consumeable
function Card.use_consumeable(self, area, copier)
    use_consumeable_ref(self, area, copier)

    local used_tarot = copier or self

    if self.ability.name == 'Polonium' then
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            local over = false
            local aura_card = G.hand.highlighted[1]
            aura_card:set_edition({ionized = true}, true)
            used_tarot:juice_up(0.3, 0.5)
        return true end }))
    end
end

local can_use_consumeable_ref = Card.can_use_consumeable
function Card.can_use_consumeable(self, any_state, skip_check)

    if self.ability.name == 'Polonium' then
        if G.hand and (#G.hand.highlighted == 1) and G.hand.highlighted[1] and (not G.hand.highlighted[1].edition) then return true end
    end

    return can_use_consumeable_ref(self, any_state, skip_check)
end

-- yeah, this sucks (override)
function get_badge_colour(key)
    G.BADGE_COL = G.BADGE_COL or {
        eternal = G.C.ETERNAL,
        foil = G.C.DARK_EDITION,
        holographic = G.C.DARK_EDITION,
        polychrome = G.C.DARK_EDITION,
        negative = G.C.DARK_EDITION,
        gold_seal = G.C.GOLD,
        red_seal = G.C.RED,
        blue_seal = G.C.BLUE,
        purple_seal = G.C.PURPLE,
        pinned_left = G.C.ORANGE,

        ionized = G.C.DARK_EDITION,
    }
    return G.BADGE_COL[key] or {1, 0, 0, 1}
end

-- as far as I can tell, an edition can only have ONE of the following: chips, mult, and x_mult.
-- for whatever reason h_mult and h_x_mult both do not work for editions
local set_edition_ref = Card.set_edition
function Card.set_edition(self, edition, immediate, silent)

    set_edition_ref(self, edition, immediate, silent)
    if edition then
        if edition.ionized then 
            if not self.edition then self.edition = {} end
            self.edition.chips = 200
            self.edition.ionized = true
            self.edition.type = 'ionized'
        end
    end

    if self.edition and not silent and edition.ionized then
        G.CONTROLLER.locks.edition = true
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = not immediate and 0.2 or 0,
            blockable = not immediate,
            func = function()
                self:juice_up(1, 0.5)
                play_sound('foil1', 1.2, 0.4)
               return true
            end
          }))
          G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                G.CONTROLLER.locks.edition = false
               return true
            end
          }))
    end
end

-- remember to implement the shader properly!
local card_draw_ref = Card.draw
function Card.draw(self, layer)
    card_draw_ref(self, layer)

    layer = layer or 'both'

    if (layer == 'shadow' or layer == 'both') then
        self.ARGS.send_to_shader = self.ARGS.send_to_shader or {}
        self.ARGS.send_to_shader[1] = math.min(self.VT.r*3, 1) + G.TIMERS.REAL/(28) + (self.juice and self.juice.r*20 or 0) + self.tilt_var.amt
        self.ARGS.send_to_shader[2] = G.TIMERS.REAL

        for k, v in pairs(self.children) do
            v.VT.scale = self.VT.scale
        end
    end

    if (layer == 'card' or layer == 'both') then
        if self.sprite_facing == 'front' then 
            if self.edition and self.edition.ionized then
                self.children.center:draw_shader('ionized', nil, self.ARGS.send_to_shader)
                if self.children.front and self.ability.effect ~= 'Stone Card' then
                    self.children.front:draw_shader('ionized', nil, self.ARGS.send_to_shader)
                end
            end

            -- copied directly from original functions, seals will get overidden visual otherwise!
            if self.seal then
                G.shared_seals[self.seal].role.draw_major = self
                G.shared_seals[self.seal]:draw_shader('dissolve', nil, nil, nil, self.children.center)
                if self.seal == 'Gold' then G.shared_seals[self.seal]:draw_shader('voucher', nil, self.ARGS.send_to_shader, nil, self.children.center) end
            end
        end
    end

    
end

-- disable if you like
local test_deck_def = {
    ["name"] = "Test Deck",
    ["text"] = {
        [1] = "Start with a Polonium.",
    }
}

function SMODS.INIT.Ionized()
    local mod = SMODS.findModByID("Ionized")
    SMODS.Sprite:new("polonium", mod.path, "polonium.png", 71, 95, "asset_atli"):register()

    SMODS.Spectral:new('Polonium', 'polonium',{} ,{x = 0, y = 0}, {
        name = 'Polonium',
        text = {
            'Ionized',
        }
    }, 4, nil, nil, 'polonium'):register()

    SMODS.Deck:new("Test Deck", "test_deck", {consumables = {'c_polonium'}}, {x = 0, y = 0}, test_deck_def):register()

    -- placing in the 'Other' section because its just easier that way
    -- change if you care THAT much about it, but it might cause issues!
    G.localization.descriptions.Other.e_ionized = {
        name = "Ionized",
        text = {
            "{C:chips}+200{} chips",
        }
    }

    G.localization.misc.labels.ionized = 'Ionized'

    -- surprisingly simple
    G.SHADERS['ionized'] = love.graphics.newShader(mod.path.."/assets/shaders/ionized.fs")

    -- insert e_ionized into the other editions
    local e_ionized = {order = 6,  unlocked = true, discovered = false, name = "Ionized", pos = {x=0,y=0}, atlas = 'Joker', set = "Edition", config = {extra = 200}}

    G.P_CENTERS['e_ionized'] = e_ionized
    table.insert(G.P_CENTER_POOLS['Edition'], e_ionized)
end


----------------------------------------------
------------MOD CODE END----------------------
