-- Ref: https://discord.com/channels/648268213859254309/648586757193072650/1255461390651494400
-- https://cdn.discordapp.com/attachments/648586757193072650/1255461604666114078/image.png?ex=668671bb&is=6685203b&hm=0216a510f177620cda13d4ef887b7a9a7b17538c6c8f282edd404fc60e2ae0be&
function mainContainerCreator(maincontainer, data)
    local uidata = {}
    for k,v in pairs(data) do
        if v.tip == "bool" then
            v.tip = DatabindingAddDataBool
            v.func = DatabindingWriteDataBool
        elseif v.tip == "string" then
            v.tip = DatabindingAddDataString
            v.func = DatabindingWriteDataString
        elseif v.tip == "hash" then
            v.tip = DatabindingAddDataHash
            v.func = DatabindingWriteDataHashString
        elseif v.tip == "int" then
            v.tip = DatabindingAddDataInt
            v.func = DatabindingWriteDataInt
        end        
        uidata[v.name] = {
            retn = v.tip(maincontainer, v.name, v.value),
            tip = function(...)
                v.tip(...)
            end,
            func = function(key,value)
                v.func(key,value)
            end
        }
    end
    return uidata
end
function bountyString(data)
    local BountyCash = DatabindingAddDataContainerFromPath("", "BountyCash")
    local data = {
        {
            tip = "string",
            name = "Text",
            value = data?.text or ""
        },
        {
            tip = "bool",
            name = "State",
            value = data?.visibility or false
        },
    }
    local bountyCashContainer = mainContainerCreator(BountyCash,data)
end

-- example --
RegisterCommand("bountyString", function()
    local data = {
        text = "Bounty: 0.80$",
        visibility = true,
    }
    bountyString(data)
    Wait(2000)
    data.text = "Bounty: 1.80$"
    bountyString(data)
    Wait(2000)
    data.visibility = false
    bountyString(data)
end)
