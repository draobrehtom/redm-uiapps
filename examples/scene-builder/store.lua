-- Write values under ScriptDatastoreRoot.<root>: Store('MatchHud') returns set(path, value).
-- Creates each entry on first use, then only writes when the value changes. The type follows the Lua value:
-- string, boolean, integer (also colour indexes) or float (meters, 0..1).
function Store(rootName)
    local root = DatabindingAddDataContainerFromPath('', rootName)
    local entries, values = {}, {}
    local function set(name, value)
        if values[name] == value then return end
        values[name] = value
        local e, t = entries[name], math.type(value) or type(value)
        if e then
            if t == 'string' then DatabindingWriteDataString(e, value)
            elseif t == 'boolean' then DatabindingWriteDataBool(e, value)
            elseif t == 'integer' then DatabindingWriteDataInt(e, value)
            else Citizen.InvokeNative(0xDF504BECEB15DA93, e, value) end -- _DATABINDING_WRITE_DATA_FLOAT
        elseif t == 'string' then entries[name] = DatabindingAddDataString(root, name, value)
        elseif t == 'boolean' then entries[name] = DatabindingAddDataBool(root, name, value)
        elseif t == 'integer' then entries[name] = DatabindingAddDataInt(root, name, value)
        else entries[name] = Citizen.InvokeNative(0x5154228273ADB9A6, root, name, value, Citizen.ResultAsInteger()) end -- _DATABINDING_ADD_DATA_FLOAT
    end
    return set, root
end
