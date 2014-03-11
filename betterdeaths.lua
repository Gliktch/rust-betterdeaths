PLUGIN.Title = "Better Deaths"
PLUGIN.Description = "Creates an easy-to-find body when you die (online), tells you who killed you in your sleep (offline), also sends you to your bag or bed on login if your sleeper was killed!"
PLUGIN.Author = "Gliktch"
PLUGIN.Version = "0.2.2"

function PLUGIN:Init()
    self:AddChatCommand("mark", self.cmdMark)
    self:AddChatCommand("boom", self.cmdBoom)
end

function PLUGIN:MarkSpot( netuser, x, y, z, marker )
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
    -- local marker = ";sleeper_male";
    local arr = util.ArrayFromTable( cs.gettype( "System.Object" ), { marker, v, q } );
    cs.convertandsetonarray( arr, 0, marker, System.String._type )
    cs.convertandsetonarray( arr, 1, v, UnityEngine.Vector3._type )
    cs.convertandsetonarray( arr, 2, q, UnityEngine.Quaternion._type )
    local spawnMarker = spawn:Invoke( nil, arr )
end

function PLUGIN:cmdMark( netuser, cmd, args )
    local coords = netuser.playerClient.lastKnownPosition;
    self.MarkSpot( netuser, "dummy", coords.x, coords.y, coords.z, ";sleeper_male" )
    rust.SendChatToUser( netuser, "Suddenly, a penis!" )
end

function PLUGIN:cmdBoom( netuser, cmd, args )
    local coords = netuser.playerClient.lastKnownPosition;
    self.MarkSpot( netuser, "dummy", coords.x, coords.y, coords.z, ";explosive_charge" )
    rust.SendChatToUser( netuser, "Tick tick, motherfucker!" )
    local Time = System.DateTime.Now:ToString("MM dd mm:ss")
    rust.BroadcastChat("System.DateTime.Now = " .. System.DateTime.Now .. ", Time = " .. Time)
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
            rust.BroadcastChat("Better Deaths: Debug - " .. damage.victim.client.netUser.displayName .. "'s pack marked at coordinates " .. self:round(coords.x,2) .. "," .. self:round(coords.y,2) .. "," .. self:round(coords.z,2) .. ".")
            self.MarkSpot( netuser, "dummy", coords.x, coords.y, coords.z, ";sleeper_male" )
            rust.SendChatToUser( netuser, "Your body falls to the ground, for you to find your belongings on your return." )
        end
    end
end

--[[
    if (dmg.attacker.client and dmg.attacker.client.netUser) then
        local myString = takedamage.gameObject.Name
        if (string.find(myString, "MaleSleeper(", 1, true)) then
            local Attacker = dmg.attacker.client.netUser
            local KillerName = Attacker.displayName
            local coords = Attacker.playerClient.lastKnownPosition
            local SleeperID = self:GetSleeperID(coords)
            local Time = System.DateTime.Now:ToString("MM dd")
            if (SleeperID ~= nil) then
                self.SleeperTable[SleeperID] = nil
                self:SetSleeperNotification(SleeperID, KillerName, Time)

function PLUGIN:GetUserData( netuser )
    local userID = rust.GetUserID( netuser )
    return self:GetUserDataFromID( userID, netuser.displayName )
end

function PLUGIN:GetUserDataFromID( userID, name )
    local userentry = self.Data[ userID ]
    if userentry and not userentry.Transfered then
        userentry.Transfered = userentry.Money
        self:SaveMapToFile(self.Data,self.DataFile)
    elseif (not userentry) then
        userentry = {}
        userentry.ID = userID
        userentry.Money = self.startMoney
        self.Data[ userID ] = userentry
        self:SaveMapToFile(self.Data,self.DataFile)
    end
    userentry.Name = name
    return userentry
end

function PLUGIN:OnUserConnect( netuser )
    local uid = rust.GetUserID( netuser )
    local data = self:GetUserData( netuser ) --init new wollet
    rust.SendChatToUser( netuser, self:printmoney(netuser) )
    if(tonumber(self.sleeperFee) > 0) then self.SleeperPos[rust.GetUserID( netuser )] = nil end


function PLUGIN:OnUserDisconnect( netuser )
    if netuser.displayName == "displayName" then
    	netuser = rust.NetUserFromNetPlayer(netuser)
    end
    local uid = rust.GetUserID( netuser )
    local coords = netuser.playerClient.lastKnownPosition;
    self.SleeperPos[uid] = coords
end

function PLUGIN:GetSleeperID(coords)
    for k,v in pairs(self.SleeperTable) do
        if (self:isPointInRadius(v,coords,tonumber(self.sleeperRad))) then
            return k   end  end
end

function PLUGIN:isPointInRadius(pos, point, rad)
    return (pos.x < point.x + rad and pos.x > point.x - rad)
            and (pos.y < point.y + rad and pos.y > point.y - rad)
            and (pos.z < point.z + rad and pos.z > point.z - rad)
end]]--
