function mod.run_store_equipment_ui( self, entity, return_entity )
    local list          = {}    
    local slots         = { "1", "2", "3", "4", "armor", "head", "utility" }
    local max_len       = 1
    local postbag_entity = entity:child( "hidden_entity_postbag" )
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

-- function mod.run_store_item_ui( self, entity, return_entity )
    -- local list          = {}    
    -- local max_len       = 1
    -- local postbag_entity = entity:child( "hidden_entity_postbag" )
    
    -- nova.log("get data")
    -- for k,v in pairs(entity.data) do
        -- nova.log(k)
    -- end
    -- nova.log("get attribute")
    -- for k,v in pairs(entity.attribute) do
        -- nova.log(k)
    -- end
    -- nova.log("get child")
    -- for k,v in pairs(entity.child) do
        -- nova.log(k)
    -- end
    
    -- for c in entity:children() do
        -- if c:get_name() then     
            -- nova.log("Child "..c:get_name())
        -- end  
        -- if c.flags and c.flags.data[ EF_ITEM ] and not c.slot and not c.weapon then
            -- nova.log("Item "..c:get_name())
            -- max_len = math.max( max_len, string.len( c:get_name() ) )
            -- table.insert( list, {
                        -- name = c:get_name(),
                        -- target = self,
                        -- parameter = c,
                        -- confirm = true,
            -- })                                  
        -- end       
    -- end
    
    -- table.insert( list, {
        -- name = ui:text("ui.lua.common.cancel"),
        -- target = return_entity or self,
        -- cancel = true,
    -- })
    -- list.title = (postbag_entity.data.max_space - postbag_entity.data.used_space).." spaces remaining."
    -- list.size  = coord( math.max( 30, max_len + 6 ), 0 )
    -- list.confirm = "Are you sure you want to send this item?"
    -- ui:terminal( entity, nil, list )
-- end

function mod.run_retrieve_ui( self, entity, return_entity )
    local list          = {}        
    local max_len       = 1
    local postbag_entity = entity:child( "hidden_entity_postbag" )

	nova.log("Checking postbag")
    for c in postbag_entity:children() do
		nova.log("postbag has children")
        if c.flags and c.flags.data[ EF_ITEM ] then
            nova.log(c:get_name())
            max_len = math.max( max_len, string.len( c:get_name() ) )
            table.insert( list, {
                name = c:get_name(),
                target = self,
                parameter = c,
                confirm = true,
            })
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
                local postbag = who:child( "hidden_entity_postbag" )
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
                        level:drop_item( who, param )
                        level:hard_place_entity( param, ivec2( 0,0 ) )
                        level:pickup( postbag, param, false )
                        postbag.data.used_space = postbag.data.used_space + 1   
                    end 
                
                    return 100
                end
            end 
        ]=]
    }, 
}

-- register_blueprint "terminal_send_item"
-- {
    -- text = {
        -- entry = "Send item",
        -- desc  = "Send an item to retrieve at a later station. Max 3 sent and awaiting collection.",
    -- },
    -- data = {
        -- terminal = {
            -- priority = 76,
        -- },
    -- },
    -- callbacks = {
        -- on_activate = [=[
            -- function( self, who, level, param )
                -- local postbag = who:child( "hidden_entity_postbag" )
                -- if not param then
                    -- if postbag and postbag.data and postbag.data.used_space == postbag.data.max_space then
                        -- ui:set_hint( "Maximum items awaiting collection", 50, 1 )
                    -- else
                        -- local parent = self:parent()
                        -- world:play_sound( "ui_terminal_accept", parent )
                        -- mod.run_store_item_ui( self, who, parent )
                        -- return -1                       
                    -- end
                -- else                                
                    -- if postbag and postbag.data and postbag.data.used_space ~= postbag.data.max_space then
                        -- nova.log("storing "..param.text.name)                        
                        -- level:drop_item( who, param )
                        -- level:hard_place_entity( param, ivec2( 0,0 ) )
                        -- level:pickup_drop( postbag, param, false )
                        -- postbag.data.used_space = postbag.data.used_space + 1   
                    -- end 
                
                    -- return 100
                -- end
            -- end 
        -- ]=]
    -- }, 
-- }

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
                local postbag = who:child( "hidden_entity_postbag" )
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
                        local parent = self:parent()
                        local pattr  = parent.attributes
                        pattr.charges = pattr.charges - 1
                        level:pickup_drop( who, param, true )
                        postbag.data.used_space = postbag.data.used_space -     1                   
                        return 100
                    end
                end
            end 
        ]=]
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
    }
}

postal_service = {}
function postal_service.on_entity( entity )	
	nova.log("postal_service.on_entity start")
    if entity.data and entity.data.ai and entity.data.ai.group == "player" then
		nova.log("Attaching postbag to player")
        entity:attach( "hidden_entity_postbag" )
    end 
    if (world:get_id(entity) == "terminal" or world:get_id(entity) == "trial_arena_terminal") then
		nova.log("Attaching send to terminal")
        entity:attach( "terminal_send_equipment" )
    end
    if (world:get_id(entity) == "medical_station") then
		nova.log("Attaching retrieve medical")
        entity:attach( "station_retrieve_equipment" )
    end
	if (world:get_id(entity) == "terminal_ammo") then
		nova.log("Attaching retrieve ammo")
        entity:attach( "station_retrieve_equipment" )
    end
	if (world:get_id(entity) == "manufacture_station") then
		nova.log("Attaching retrieve manufacture")
        entity:attach( "station_retrieve_equipment" )
    end
	if (world:get_id(entity) == "technical_station") then
		nova.log("Attaching retrieve technical")
        entity:attach( "station_retrieve_equipment" )
    end
	nova.log("postal_service.on_entity end")
end

world.register_on_entity( postal_service.on_entity )