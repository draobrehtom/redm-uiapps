-- https://github.com/vRedM/vRedM/blob/4daefbe02acebe709c4923da677a189973080143/client/modules/test.lua#L12

RegisterCommand("subtitle", function()
    local msg = "indra is gay"
    local str = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", msg, Citizen.ResultAsLong())
    Citizen.InvokeNative(0xFA233F8FE190514C, str)
    Citizen.InvokeNative(0xE9990552DEC71600)
    local a = Citizen.InvokeNative(0xDFF0D417277B41F8, Citizen.ResultAsInteger())
end)

RegisterCommand("translate", function(source, args)
 
    LaunchAppByHashWithEntry(GetHashKey("TRANSLATION_OVERLAY"), GetHashKey("CATALOGUE"))
    local Translate = DatabindingAddDataContainerFromPath("", "Translate");
    local Catalogue = DatabindingAddDataContainer(Translate, "Catalogue");
 
    local textField = DatabindingAddDataContainer(Catalogue, 'textField0');
    DatabindingAddDataString(textField, "text", "Bienvenue sur le serveur de dlaV");
    DatabindingAddDataInt(textField, "style", 0);
 
    local textField = DatabindingAddDataContainer(Catalogue, 'textField1');
    DatabindingAddDataHash(textField, "text", GetHashKey("MOONSHINERSADDLE_01_IMPROVED_SADDLE_CATALOGUEDESC"));
    DatabindingAddDataInt(textField, "style", 1);
    local divider = DatabindingAddDataContainer(Catalogue, "divider0");
    DatabindingAddDataBool(divider, "isVisible", true);
 
 
    local textField = DatabindingAddDataContainer(Catalogue, 'textField2');
    DatabindingAddDataString(textField, "text", "textField2");
    DatabindingAddDataInt(textField, "style", 2);
    local divider = DatabindingAddDataContainer(Catalogue, "divider1");
    DatabindingAddDataBool(divider, "isVisible", true);
    
 
    local textField = DatabindingAddDataContainer(Catalogue, 'textField3');
    DatabindingAddDataHash(textField, "text", GetHashKey("MOONSHINERSADDLE_01_IMPROVED_SADDLE_CATALOGUEDESC"));
    DatabindingAddDataInt(textField, "style", 3);
 
    local textField = DatabindingAddDataContainer(Catalogue, 'textField4');
    DatabindingAddDataHash(textField, "text", GetHashKey("MOONSHINERSADDLE_01_IMPROVED_SADDLE_CATALOGUEDESC"));
    DatabindingAddDataInt(textField, "style", 4);
 
    Wait(1000) -- Can be cleared while after open ??can cause issues??
    if Citizen.InvokeNative(0x1E7130793AAAAB8D, Translate) then
        DatabindingRemoveDataEntry(Catalogue);
        DatabindingRemoveDataEntry(Translate);
    end
end)


RegisterCommand("shop", function(source, args)
 
    local Block = RequestFlowBlock(GetHashKey("SHOP_BROWSING_MAIN_FLOW"))
 
    local DynamicCatalogItems = DatabindingAddDataContainerFromPath("", "DynamicCatalogItems");
    local CatalogItemInspection = DatabindingAddDataContainer(DynamicCatalogItems, "CatalogItemInspection");
 
    DatabindingAddDataBool(CatalogItemInspection, "isVisible", true);
    DatabindingAddDataHash(CatalogItemInspection, "itemLabel", GetHashKey("WEAPON_PISTOL_VOLCANIC"));
    DatabindingAddDataString(CatalogItemInspection, "itemDescription", "itemDescription");
    DatabindingAddDataString(CatalogItemInspection, "purchaseLabel", "purchaseLabel");
    DatabindingAddDataInt(CatalogItemInspection, "purchasePrice", 1000);
    DatabindingAddDataInt(CatalogItemInspection, "tokenPrice", 1);
    DatabindingAddDataBool(CatalogItemInspection, "isGoldPrice", false);
    DatabindingAddDataInt(CatalogItemInspection, "purchaseModifiedPrice", 1200);
    DatabindingAddDataBool(CatalogItemInspection, "modifiedPriceVisible", true);
    DatabindingAddDataBool(CatalogItemInspection, "modifiedPriceGold", false);
    DatabindingAddDataBool(CatalogItemInspection, "ammoVisible", true);
    DatabindingAddDataInt(CatalogItemInspection, "ammoCurrent", 10);
    DatabindingAddDataInt(CatalogItemInspection, "ammoMax", 100);
    DatabindingAddDataString(CatalogItemInspection, "ammoTextureDictionary", "ammo_types");
    DatabindingAddDataString(CatalogItemInspection, "ammoTexture", "arrow_type_fire");
    DatabindingAddDataBool(CatalogItemInspection, "mailVisible", true);
    DatabindingAddDataInt(CatalogItemInspection, "mailCurrent", 5);
 
    while not Citizen.InvokeNative(0x10A93C057B6BD944, Block) do
        Wait(1)
    end
    Citizen.InvokeNative(0x3B7519720C9DCB45, Block, -702860656)
    Citizen.InvokeNative(0x4C6F2C4B7A03A266, -1468895189, Block)
    Wait(5000)
    Citizen.InvokeNative(0x4EB122210A90E2D8, -1468895189)
    
    DatabindingRemoveDataEntry(CatalogItemInspection)
    DatabindingRemoveDataEntry(DynamicCatalogItems)
end)



RegisterCommand("shop", function(source, args)
 
    local Block = RequestFlowBlock(GetHashKey("SHOP_BROWSING_MAIN_FLOW"))
 
    local DynamicCatalogItems = DatabindingAddDataContainerFromPath("", "DynamicCatalogItems");
    local CatalogItemInspection = DatabindingAddDataContainer(DynamicCatalogItems, "CatalogItemInspection");
 
    DatabindingAddDataBool(CatalogItemInspection, "isVisible", true);
    DatabindingAddDataHash(CatalogItemInspection, "itemLabel", GetHashKey("WEAPON_PISTOL_VOLCANIC"));
    DatabindingAddDataString(CatalogItemInspection, "itemDescription", "itemDescription");
    DatabindingAddDataString(CatalogItemInspection, "purchaseLabel", "purchaseLabel");
    DatabindingAddDataInt(CatalogItemInspection, "purchasePrice", 1000);
    DatabindingAddDataInt(CatalogItemInspection, "tokenPrice", 1);
    DatabindingAddDataBool(CatalogItemInspection, "isGoldPrice", false);
    DatabindingAddDataInt(CatalogItemInspection, "purchaseModifiedPrice", 1200);
    DatabindingAddDataBool(CatalogItemInspection, "modifiedPriceVisible", true);
    DatabindingAddDataBool(CatalogItemInspection, "modifiedPriceGold", false);
    DatabindingAddDataBool(CatalogItemInspection, "ammoVisible", true);
    DatabindingAddDataInt(CatalogItemInspection, "ammoCurrent", 10);
    DatabindingAddDataInt(CatalogItemInspection, "ammoMax", 100);
    DatabindingAddDataString(CatalogItemInspection, "ammoTextureDictionary", "ammo_types");
    DatabindingAddDataString(CatalogItemInspection, "ammoTexture", "arrow_type_fire");
    DatabindingAddDataBool(CatalogItemInspection, "mailVisible", true);
    DatabindingAddDataInt(CatalogItemInspection, "mailCurrent", 5);
 
    while not Citizen.InvokeNative(0x10A93C057B6BD944, Block) do
        Wait(1)
    end
    Citizen.InvokeNative(0x3B7519720C9DCB45, Block, -702860656)
    Citizen.InvokeNative(0x4C6F2C4B7A03A266, -1468895189, Block)
    Wait(5000)
    Citizen.InvokeNative(0x4EB122210A90E2D8, -1468895189)
    
    DatabindingRemoveDataEntry(CatalogItemInspection)
    DatabindingRemoveDataEntry(DynamicCatalogItems)
end)
