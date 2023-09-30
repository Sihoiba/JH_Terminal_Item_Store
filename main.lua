function mod.run_store_ui( self, entity, return_entity )
    local list          = {}	
    local slots         = { "1", "2", "3", "4" }
    local max_len       = 1
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
	local used = 3
    if entity.data.stored_limit then
		used = entity.data.stored_limit
	end
	
    table.insert( list, {
        name = ui:text("ui.lua.common.cancel"),
        target = return_entity or self,
        cancel = true,
    })
    list.title = used.." spaces remaining."
    list.size  = coord( math.max( 30, max_len + 6 ), 0 )
    list.confirm = "Are you sure you want to store this item?"
    ui:terminal( entity, nil, list )
end

function mod.run_retrieve_ui( self, entity, return_entity )
    local list          = {}	    
    local max_len       = 1
	if world:get_player() == entity then
		nova.log("entity is player")
	end	
	for k,v in ipairs(entity.data.stored) do
		nova.log(k)
		nova.log(type(v))
		for k2,v2 in ipairs(v) do
			nova.log(k2)
			nova.log(v2)
		end
	end
    max_len = math.max( max_len, string.len( entity.data.stored[1].text.name ) )	
    table.insert( list, {
        name = entity.data.stored[1].text.name,
        target = self,
        parameter = entity.data.stored[1],
        confirm = true,
    })	
	
    table.insert( list, {
        name = ui:text("ui.lua.common.cancel"),
        target = return_entity or self,
        cancel = true,
    })
    list.title = "Retrieve stored item."
    list.size  = coord( math.max( 30, max_len + 6 ), 0 )
    list.confirm = "Are you sure you want to retrieve this item?"
    ui:terminal( entity, nil, list )
end

register_blueprint "station_store_weapon"
{
	text = {
		entry = "Store weapon",
		desc  = "Store a weapon to retrieve at a later manufacture or technical station.",
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
				if not param then
					if who.data.stored and who.data.stored_limit == 0 then
						ui:set_hint( "No storage space left", 50, 1 )
					else
						local parent = self:parent()
						world:play_sound( "ui_terminal_accept", parent )
						mod.run_store_ui( self, who, parent )
						return -1						
					end
				else
                	local parent = self:parent()
                	local pattr  = parent.attributes
                	pattr.charges = pattr.charges - 1
					if who.data.stored then
						if who.data.stored_limit > 0 then
							who.data.stored_limit = who.data.stored_limit - 1
							table.insert( who.data.stored, param )
							world:stash_item( self, param )
							level:drop_item( who, param )
							-- world:destroy( param )
						end
					else 				
						who.data.stored = {}						
						who.data.stored_limit = 2					
						nova.log("storing "..param.text.name)
						table.insert( who.data.stored, param )
						nova.log("stored "..who.data.stored[1].text.name)
						world:stash_item( self, param )
						nova.log("stashed stored "..who.data.stored[1].text.name)
						nova.log("stashed param "..param.text.name)
						level:drop_item( who, param )
						-- world:destroy( param )
						-- nova.log("stashed destroyed? stored "..who.data.stored[1].text.name)
						nova.log(type(who.data.stored[1]))
					end	
					
					return 100
				end
			end	
		]=]
	}, 
}

register_blueprint "station_retrieve_weapon"
{
	text = {
		entry = "Retrieve stored weapon",
		desc  = "Retrieve a weapon previously stored.",
	},
	data = {
		terminal = {
			priority = 76,
		},
	},
    attributes = {
        charge_cost = 1,
    },
	callbacks = {
		on_activate = [=[
			function( self, who, level, param )
				if not param then					
					if who.data.stored == nil or (who.data.stored and who.data.stored_limit == 3) then
						ui:set_hint( "Nothing stored", 50, 1 )
					else
						local parent = self:parent()
						world:play_sound( "ui_terminal_accept", parent )
						mod.run_retrieve_ui( self, who, parent )
						return -1						
					end
				else
					nova.log("retrieving "..param.text.name)
                	local parent = self:parent()
                	local pattr  = parent.attributes
                	pattr.charges = pattr.charges - 1
					who.data.stored_limit = who.data.stored_limit + 1					
					level:pickup_drop( who, param, true )
					table.remove( who.data.stored, 1 )
					
					return 100
				end
			end	
		]=]
	}, 
}

register_blueprint "terminal_ammo"
{
	flags = { EF_NOMOVE, EF_NOFLY, EF_BUMPACTION, EF_ACTION, EF_HARD_COVER },
	text = {
		name      = "ammo station",
		entry     = "Ammo manufacture station",
		header    = "CoreTek ammo manufacture 0.9.6",

		manufacture = "Manufacture ",
		sub_ammo    = "Manufacture ammo",
		sub_grenade = "Manufacture grenades",
	},
	lists = {
		group    = "lootbox",
		keywords = { "lootbox", },
		weight   = 2,
		dmin     = 12,
	},
	ascii     = {
		glyph     = "&",
		color     = YELLOW,
	},
	attributes = {
		charges = 2,
		found   = 0,
	},
	data = {
		terminal = {
			params = {
				fsize    = 2,
				size     = coord( 40, 0 ), 
				hsize    = 2,
				no_title = true,
			},
		},
	},
	minimap   = {
		color  = tcolor( GREEN, ivec3( 0, 128, 0 ) ),
		reveal = true,
	},
	callbacks = {
		on_create = [=[
			function( self )
				world:get_player().statistics.data.loot:inc()
				local ammo = self:attach("terminal_ammo_manufacture_sub")
				ammo.text.entry             = self.text.sub_ammo
				ammo.data.terminal.priority = 10

				local nade = self:attach("terminal_ammo_manufacture_sub")
				nade.text.entry             = self.text.sub_grenade
				nade.data.terminal.priority = 20


				local function add( root, amount, id, priority, cost )
					local e    = root:attach("terminal_ammo_manufacture")
					local name = world:get_text( id, "pname" )
					if amount == 1 or not name or #name == 0 then
						name = world:get_text( id, "name" )
					end
					e.text.entry = self.text.manufacture..name
					e.attributes.charge_cost = 1
					local t = e.data.terminal
					t.id = id
					t.amount = amount
					t.tier = tier
					t.priority = priority
				end
				add( ammo, 50, "ammo_9mm", 10, 1 )
				add( ammo, 50, "ammo_44", 20, 1 )
				add( ammo, 10, "ammo_40", 25, 1 )
				add( ammo, 50, "ammo_762", 30, 1 )
				add( ammo, 50, "ammo_shells", 40, 1 )
				add( ammo, 5,  "ammo_rockets", 50, 1 )
				add( ammo, 50, "ammo_cells", 60, 1 )

				add( nade, 1, "frag_grenade", 70, 1 )
				add( nade, 1, "krak_grenade", 80, 1 )
				add( nade, 1, "gas_grenade", 90, 1 )
				add( nade, 1, "napalm_grenade", 100, 1 )
				add( nade, 1, "emp_grenade", 110, 1 )

				ammo:attach( "terminal_back" )
				nade:attach( "terminal_back" )

				self:attach( "station_store_weapon" )
				self:attach( "station_retrieve_weapon" )

				self:attach( "station_charge" )
				self:attach( "terminal_return" )
			end
		]=],
		on_activate = [=[
			function( self, who, level, param )
				if who == world:get_player() then
					if self.attributes.found == 0 then
						world:get_player().statistics.data.loot_found:inc()
						self.attributes.found = 1
					end
					level:rotate_towards( self, who )
					world:lua_callback( who, "on_terminal_activate", self )
					uitk.station_activate( who, self, true )
					return 1
				else 
					return 0
				end
			end
		]=],
	},
}