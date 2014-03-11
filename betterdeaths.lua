PLUGIN.Title = "Better Deaths"
PLUGIN.Description = "Creates an easy-to-find body when you die (online), tells you who killed you in your sleep (offline), also sends you to your bag or bed on login if your sleeper was killed!"
PLUGIN.Author = "Gliktch"
PLUGIN.Version = "0.2.0"

function PLUGIN:Init()
    self:AddChatCommand("mark", self.cmdMark)
end

function PLUGIN:MarkSpot( netuser, x, y, z )
    local spawn = util.FindOverloadedMethod( Rust.NetCull._type, "InstantiateStatic", bf.public_static, { System.String, UnityEngine.Vector3, UnityEngine.Quaternion } )
    local v = new(UnityEngine.Vector3)
    local q = new(UnityEngine.Quaternion)
    -- Location of object in map
    v.x = x
    v.y = ( y - 1.7 )
    v.z = z
    local slant = util.GetStaticMethod( UnityEngine.Quaternion._type, "LookRotation" )
    q = slant[1]:Invoke( nil, util.ArrayFromTable( cs.gettype( "System.Object" ), { v } ) )
    if spawn == nil then
        error("Better Deaths: MarkSpot() - Failed to find overload!")
        return false
    end
    -- alternative marker items
    -- ;sleeper_male
    -- ;deploy_camp_bonfire (can't light yet :()
    -- ;struct_wooden_pillar
    -- ;struct_metal_pillar
    -- ;deploy_wood_box
    local marker = ";sleeper_male";
    local arr = util.ArrayFromTable( cs.gettype( "System.Object" ), { marker, v, q } );
    cs.convertandsetonarray( arr, 0, marker, System.String._type )
    cs.convertandsetonarray( arr, 1, v, UnityEngine.Vector3._type )
    cs.convertandsetonarray( arr, 2, q, UnityEngine.Quaternion._type )
    local spawnMarker = spawn:Invoke( nil, arr )
end

function PLUGIN:cmdMark( netuser, cmd, args )
    local coords = netuser.playerClient.lastKnownPosition;
    self.MarkSpot( netuser, "dummy", coords.x, coords.y, coords.z )
    rust.SendChatToUser( netuser, "Suddenly, a penis!" )
end

function PLUGIN:OnKilled(takedamage, damage)
    if not (tostring(type(damage) ~= "userdata")) or not (tostring(type(takedamage) ~= "userdata")) then
    	return
	end
    if (takedamage:GetComponent( "HumanController" )) then
    	if (damage.victim.client) then
    	    local netuser = damage.victim.client.netUser;
            if (damage.attacker.client) then
			    if (damage.victim.client == damage.attacker.client) then
                    rust.SendChatToUser( netuser, "Not marking pack for suicide - if you're offing yourself, you should get your bearings first!" )
                    return
                end
            end
            local coords = netuser.playerClient.lastKnownPosition;
            rust.BroadcastChat("Better Deaths: Debug - " .. damage.victim.client.netUser.displayName .. "'s pack marked at coordinates " .. coords.x .. "," .. coords.y .. "," .. coords.z .. ".")
            self.MarkSpot( netuser, "dummy", coords.x, coords.y, coords.z )
            rust.SendChatToUser( netuser, "Your body falls to the ground, for you to find your belongings on your return." )
        end
    end
end
