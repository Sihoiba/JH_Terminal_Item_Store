function get_postbag()
    local player = world:get_player()
    local postbag = player:child("hidden_entity_postbag")
    if not postbag then
        nova.log("postbag missing!")
    end
    return postbag
end

function mod.run_store_equipment_ui( self, entity, return_entity )
    local list          = {}
    local slots         = { "1", "2", "3", "4", "armor", "head", "utility" }
    local max_len       = 1
    local postbag_entity = get_postbag()
    for _,slot_id in ipairs( slots ) do
        local slot     = entity:get_slot( slot_id )
        if slot then
                max_len = math.max( max_len, string.len( slot:get_name() ) )
                table.insert( list, {
                    name = slot:get_name(),
                    target = self,
                    parameter = slot,
                    confirm = true,
                })
        end
    end

    table.insert( list, {
        name = ui:text("ui.lua.common.cancel"),
        target = return_entity or self,
        cancel = true,
    })
    list.title = (postbag_entity.data.max_space - postbag_entity.data.used_space).." spaces remaining"
    list.size  = coord( math.max( 30, max_len + 6 ), 0 )
    list.confirm = "Are you sure you want to send this equipment?"
    ui:terminal( entity, nil, list )
end

function mod.run_retrieve_ui( self, entity, return_entity )
    local list          = {}
    local max_len       = 1
    local postbag_entity = get_postbag()

    for b in postbag_entity:children() do
        for c in b:children() do
            if c.flags and c.flags.data[ EF_ITEM ] then
                max_len = math.max( max_len, string.len( c:get_name() ) )
                table.insert( list, {
                    name = c:get_name(),
                    target = self,
                    parameter = c,
                    confirm = true,
                })
            end
        end
    end

    table.insert( list, {
        name = ui:text("ui.lua.common.cancel"),
        target = return_entity or self,
        cancel = true,
    })
    list.title = "Retrieve sent equipment"
    list.size  = coord( math.max( 30, max_len + 6 ), 0 )
    list.confirm = "Are you sure you want to retrieve this?"
    ui:terminal( entity, nil, list )
end

register_blueprint "terminal_send_equipment"
{
    text = {
        entry = "Send equipment",
        desc  = "JoviSec Delivery Module 0.6.6\nSend equipment to retrieve later at stations. Max 3 out for delivery.",
    },
    data = {
        terminal = {
            priority = 75,
        },
    },
    callbacks = {
        on_activate = [=[
            function( self, who, level, param )
                local postbag = get_postbag()
                if not param then
                    if postbag and postbag.data and postbag.data.used_space == postbag.data.max_space then
                        ui:set_hint( "Maximum items awaiting collection", 50, 1 )
                    else
                        local parent = self:parent()
                        world:play_sound( "ui_terminal_accept", parent )
                        mod.run_store_equipment_ui( self, who, parent )
                        return -1
                    end
                else
                    if postbag and postbag.data and postbag.data.used_space ~= postbag.data.max_space then
                        nova.log("storing "..param.text.name)
                        if param.text.name == "Cybersuit" then
                            ui:set_hint( "The Cybersuit doesn't come off!", 50, 1 )
                            return
                        end
                        if param.armor and param.health then
                            if not param.data then
                                param.data = {}
                            end
                            if not param.armor.permanent then
                                param.data.not_permanent = true
                                param.armor.permanent = true
                            end
                            param.data.stored_health = param.health.current
                        end

                        local before_acid_resist = who:attribute("resist", "acid")
                        local before_adrenaline_bonus = who:attribute("adrenaline_bonus")
                        local before_aim_bonus = who:attribute("aim_bonus")
                        local before_bleed_resist = who:attribute("resist", "bleed")
                        local before_cold_resist = who:attribute("resist", "cold")
                        local before_crit_chance = who:attribute("crit_chance")
                        local before_crit_damage = who:attribute("crit_damage")
                        local before_crit_defence = who:attribute("crit_defence")
                        local before_dodge_max = who:attribute("dodge_max")
                        local before_dodge_value = who:attribute("dodge_value")
                        local before_energy_bonus = who:attribute("energy_bonus")
                        local before_experience_mult = param:attribute("experience_mult")
                        nova.log("before_experience_mult"..before_experience_mult)
                        if before_experience_mult and before_experience_mult == 0 then
                            for c in ecs:children( param ) do
                                if c.attributes and c.attributes.experience_mult then
                                    nova.log(c:get_name()..c.attributes.experience_mult)
                                    before_experience_mult = c.attributes.experience_mult
                                end
                            end
                        end
                        local before_fury_bonus = who:attribute("fury_bonus")
                        local before_hacking = who:attribute("hacking")
                        local before_ignite_resist = who:attribute("resist", "ignite")
                        local before_inv_capacity = who:attribute("inv_capacity")
                        local before_max_distance = who:attribute("max_distance")
                        local before_medkit_mod = param:attribute("medkit_mod")
                        nova.log("before_medkit_mod"..before_medkit_mod)
                        if before_medkit_mod and before_medkit_mod == 1 then
                            for c in ecs:children( param ) do
                                if c.attributes and c.attributes.medkit_mod then
                                    nova.log(c:get_name()..c.attributes.medkit_mod)
                                    before_medkit_mod = c.attributes.medkit_mod
                                end
                            end
                        end
                        local before_melee_guard_mod = param:attribute("melee_guard_mod")
                        nova.log("before_melee_guard_mod"..before_melee_guard_mod)
                        if before_melee_guard_mod and before_melee_guard_mod == 0 then
                            for c in ecs:children( param ) do
                                if c.attributes and c.attributes.melee_guard_mod then
                                    nova.log(c:get_name()..c.attributes.melee_guard_mod)
                                    before_melee_guard_mod = c.attributes.melee_guard_mod
                                end
                            end
                        end
                        local before_melee_resist = who:attribute("resist", "melee")
                        local before_min_vision = who:attribute("min_vision")
                        local before_move_time = param:attribute("move_time")
                        nova.log("before_move_time"..before_move_time)
                        if before_move_time and before_move_time == 0 then
                            for c in ecs:children( param ) do
                                if c.attributes and c.attributes.move_time then
                                    nova.log(c:get_name()..c.attributes.move_time)
                                    before_move_time = c.attributes.move_time
                                end
                            end
                        end
                        local before_multikit_mod = param:attribute("multikit_mod")
                        nova.log("before_multikit_mod"..before_multikit_mod)
                        if before_multikit_mod and before_multikit_mod == 1 then
                            for c in ecs:children( param ) do
                                if c.attributes and c.attributes.multikit_mod then
                                    nova.log(c:get_name()..c.attributes.multikit_mod)
                                    before_multikit_mod = c.attributes.multikit_mod
                                end
                            end
                        end
                        local before_opt_distance = who:attribute("opt_distance")
                        local before_pain_reduction = who:attribute("pain_reduction")
                        local before_power_bonus = who:attribute("power_bonus")
                        local before_smoke_range_bonus = who:attribute("smoke_range_bonus")
                        local before_speed = param:attribute("speed")
                        nova.log("before_speed"..before_speed)
                        if before_speed and before_speed == 0 then
                            for c in ecs:children( param ) do
                                if c.attributes and c.attributes.speed then
                                    nova.log(c:get_name()..c.attributes.speed)
                                    before_speed = c.attributes.speed
                                end
                            end
                        end
                        local before_splash_mod = param:attribute("splash_mod")
                        nova.log("before_splash_mod"..before_splash_mod)
                        if before_splash_mod and before_splash_mod == 0 then
                            for c in ecs:children( param ) do
                                if c.attributes and c.attributes.splash_mod then
                                    nova.log(c:get_name()..c.attributes.splash_mod)
                                    before_splash_mod = c.attributes.splash_mod
                                end
                            end
                        end
                        local before_stealth_duration_bonus = who:attribute("stealth_duration_bonus")
                        local before_stealth_shot_bonus = who:attribute("stealth_shot_bonus")
                        local before_tenacity_bonus = who:attribute("tenacity_bonus")
                        local before_toxin_resist = who:attribute("resist", "toxin")
                        local before_use_time = param:attribute("use_time")
                        if before_use_time and before_use_time == 0 then
                            for c in ecs:children( param ) do
                                if c.attributes and c.attributes.use_time then
                                    nova.log(c:get_name()..c.attributes.use_time)
                                    before_use_time = c.attributes.use_time
                                end
                            end
                        end

                        level:drop_item( who, param )
                        level:hard_place_entity( param, ivec2( 0,0 ) )

                        local after_acid_resist = who:attribute("resist", "acid")
                        local after_adrenaline_bonus = who:attribute("adrenaline_bonus")
                        local after_aim_bonus = who:attribute("aim_bonus")
                        local after_bleed_resist = who:attribute("resist", "bleed")
                        local after_cold_resist = who:attribute("resist", "cold")
                        local after_crit_chance = who:attribute("crit_chance")
                        local after_crit_damage = who:attribute("crit_damage")
                        local after_crit_defence = who:attribute("crit_defence")
                        local after_dodge_max = who:attribute("dodge_max")
                        local after_dodge_value = who:attribute("dodge_value")
                        local after_energy_bonus = who:attribute("energy_bonus")
                        local after_fury_bonus = who:attribute("fury_bonus")
                        local after_hacking = who:attribute("hacking")
                        local after_ignite_resist = who:attribute("resist", "ignite")
                        local after_inv_capacity = who:attribute("inv_capacity")
                        local after_max_distance = who:attribute("max_distance")                        
                        local after_melee_resist = who:attribute("resist", "melee")
                        local after_min_vision = who:attribute("min_vision")                        
                        local after_opt_distance = who:attribute("opt_distance")
                        local after_pain_reduction = who:attribute("pain_reduction")
                        local after_power_bonus = who:attribute("power_bonus")
                        local after_smoke_range_bonus = who:attribute("smoke_range_bonus")
                        local after_stealth_duration_bonus = who:attribute("stealth_duration_bonus")
                        local after_stealth_shot_bonus = who:attribute("stealth_shot_bonus")
                        local after_tenacity_bonus = who:attribute("tenacity_bonus")
                        local after_toxin_resist = who:attribute("resist", "toxin")

                        for c in ecs:children( postbag ) do
                            if c.data and c.data.empty then
                                c.data.empty = false
                                level:pickup( c, param, false )

                                if after_acid_resist ~= before_acid_resist then
                                    c.attributes["acid.resist"] = after_acid_resist - before_acid_resist
                                end
                                if after_adrenaline_bonus ~= before_adrenaline_bonus then
                                    c.attributes.adrenaline_bonus = after_adrenaline_bonus - before_adrenaline_bonus
                                end
                                if after_aim_bonus ~= before_aim_bonus then
                                    c.attributes.aim_bonus = after_aim_bonus - before_aim_bonus
                                end
                                if after_bleed_resist ~= before_bleed_resist then
                                    c.attributes["bleed.resist"] = after_bleed_resist - before_bleed_resist
                                end
                                if after_cold_resist ~= before_cold_resist then
                                    c.attributes["cold.resist"] = after_cold_resist - before_cold_resist
                                end
                                if after_crit_chance ~= before_crit_chance then
                                    c.attributes.crit_chance = after_crit_chance - before_crit_chance
                                end
                                if after_crit_damage ~= before_crit_damage then
                                    c.attributes.crit_damage = after_crit_damage - before_crit_damage
                                end
                                if after_crit_defence ~= before_crit_defence then
                                    c.attributes.crit_defence = after_crit_defence - before_crit_defence
                                end
                                if after_dodge_max ~= before_dodge_max then
                                    c.attributes.dodge_max = after_dodge_max - before_dodge_max
                                end
                                if after_dodge_value ~= before_dodge_value then
                                    c.attributes.dodge_value = after_dodge_value - before_dodge_value
                                end
                                if after_energy_bonus ~= before_energy_bonus then
                                    c.attributes.energy_bonus = after_energy_bonus - before_energy_bonus
                                end
                                if before_experience_mult and before_experience_mult > 0 then
                                    c.attributes.experience_mult = 1.0/before_experience_mult
                                end
                                if after_fury_bonus ~= before_fury_bonus then
                                    c.attributes.fury_bonus = after_fury_bonus - before_fury_bonus
                                end
                                if after_hacking ~= before_hacking then
                                    c.attributes.hacking = after_hacking - before_hacking
                                end
                                if after_ignite_resist ~= before_ignite_resist then
                                    c.attributes["ignite.resist"] = after_ignite_resist - before_ignite_resist
                                end
                                if after_inv_capacity ~= before_inv_capacity then
                                    c.attributes.inv_capacity = after_inv_capacity - before_inv_capacity
                                end
                                if after_max_distance ~= before_max_distance then
                                    c.attributes.max_distance = after_max_distance - before_max_distance
                                end
                                if before_medkit_mod and before_medkit_mod > 0 then
                                    c.attributes.medkit_mod = 1.0/before_medkit_mod
                                end
                                if before_melee_guard_mod and before_melee_guard_mod > 0 then
                                    c.attributes.melee_guard_mod = 1.0/before_melee_guard_mod
                                end
                                if after_melee_resist ~= before_melee_resist then
                                    c.attributes["melee.resist"] = after_melee_resist - before_melee_resist
                                end
                                if after_min_vision ~= before_min_vision then
                                    c.attributes.min_vision = after_min_vision - before_min_vision
                                end
                                if before_move_time and before_move_time > 0 then
                                    c.attributes.move_time = 1.0/before_move_time
                                end
                                if before_multikit_mod and before_multikit_mod > 0 then
                                    c.attributes.multikit_mod = 1.0/before_multikit_mod
                                end
                                if after_opt_distance ~= before_opt_distance then
                                    c.attributes.opt_distance = after_opt_distance - before_opt_distance
                                end
                                if after_pain_reduction ~= before_pain_reduction then
                                    c.attributes.pain_reduction = after_pain_reduction - before_pain_reduction
                                end
                                if after_power_bonus ~= before_power_bonus then
                                    c.attributes.power_bonus = after_power_bonus - before_power_bonus
                                end
                                if after_smoke_range_bonus ~= before_smoke_range_bonus then
                                    c.attributes.smoke_range_bonus = after_smoke_range_bonus - before_smoke_range_bonus
                                end
                                if before_speed and before_speed > 0 then
                                    c.attributes.speed = 1.0/before_speed
                                end
                                if before_splash_mod and before_splash_mod > 0 then
                                    c.attributes.splash_mod = 1.0/before_splash_mod
                                end
                                if after_stealth_duration_bonus ~= before_stealth_duration_bonus then
                                    c.attributes.stealth_duration_bonus = after_stealth_duration_bonus - before_stealth_duration_bonus
                                end
                                if after_stealth_shot_bonus ~= before_adrenaline_bonus then
                                    c.attributes.stealth_shot_bonus = after_stealth_shot_bonus - before_stealth_shot_bonus
                                end
                                if after_tenacity_bonus ~= before_tenacity_bonus then
                                    c.attributes.tenacity_bonus = after_tenacity_bonus - before_tenacity_bonus
                                end
                                if after_toxin_resist ~= before_toxin_resist then
                                    c.attributes["toxin.resist"] = after_toxin_resist - before_toxin_resist
                                end
                                if before_use_time and before_use_time > 0 then
                                    c.attributes.use_time = 1.0/before_use_time
                                end

                                break
                            end
                        end
                        postbag.data.used_space = postbag.data.used_space + 1

                    end

                    return 100
                end
            end
        ]=]
    },
}

register_blueprint "station_retrieve_equipment"
{
    text = {
        entry = "Retrieve sent equipment",
        desc  = "JoviSec Delivery Module 0.6.6\nRetrieve an equipment previously sent to yourself.",
    },
    data = {
        terminal = {
            priority = 75,
        },
    },
    attributes = {
        charge_cost = 1,
    },
    callbacks = {
        on_activate = [=[
            function( self, who, level, param )
                local postbag = get_postbag()
                if not param then
                    if postbag and postbag.data and postbag.data.used_space == 0 then
                        ui:set_hint( "Nothing sent", 50, 1 )
                    else
                        local parent = self:parent()
                        world:play_sound( "ui_terminal_accept", parent )
                        mod.run_retrieve_ui( self, who, parent )
                        return -1
                    end
                else
                    if postbag and postbag.data and postbag.data.used_space > 0 then
                        nova.log("retrieving "..param.text.name)
                        if param.armor and param.data and param.data.stored_health and param.health then
                            param.health.current = param.data.stored_health
                            if param.data.not_permanent then
                                param.data.permanent = false
                            end
                        end
                        local parent = self:parent()
                        local pattr  = parent.attributes
                        pattr.charges = pattr.charges - 1
                        local param_parent = param:parent()
                        level:pickup_drop( who, param, true )
                        postbag.data.used_space = postbag.data.used_space - 1
                        world:destroy( param_parent )
                        postbag:attach("hidden_entity_sub_postbag")
                        return 100
                    end
                end
            end
        ]=]
    },
}

register_blueprint "hidden_entity_sub_postbag"
{
    flags = { EF_NOPICKUP },
    data = {
        empty = true
    },
    attributes = {
    },
}

register_blueprint "hidden_entity_postbag"
{
    flags = { EF_NOPICKUP },
    data = {
        max_space = 3,
        used_space = 0,
        equipment = {
            count = 3
        }
    },
    callbacks = {
        on_create = [[
            function( self )
                self:attach("hidden_entity_sub_postbag")
                self:attach("hidden_entity_sub_postbag")
                self:attach("hidden_entity_sub_postbag")
            end
        ]],
    }
}

postal_service = {}
function postal_service.on_entity( entity )
    if entity.data and entity.data.ai and entity.data.ai.group == "player" then
        nova.log("Postbag is attached to the player")
        entity:attach( "hidden_entity_postbag" )
    end
    if (world:get_id(entity) == "terminal" or world:get_id(entity) == "trial_arena_terminal") then
        entity:attach( "terminal_send_equipment" )
    end
    if (world:get_id(entity) == "medical_station") then
        entity:attach( "station_retrieve_equipment" )
    end
    if (world:get_id(entity) == "terminal_ammo") then
        entity:attach( "station_retrieve_equipment" )
    end
    if (world:get_id(entity) == "manufacture_station") then
        entity:attach( "station_retrieve_equipment" )
    end
    if (world:get_id(entity) == "technical_station") then
        entity:attach( "station_retrieve_equipment" )
    end
end
world.register_on_entity( postal_service.on_entity )