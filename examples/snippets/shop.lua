-- Ref: https://discord.com/channels/846719561020473364/987235576308703292/1144190765585670225
-- https://cdn.discordapp.com/attachments/987235576308703292/1144190764075720795/image.png?ex=66866130&is=66850fb0&hm=b4280ef0c9d012133a3cc036bb08143781ad8bdae74ae90f9fef0c989bdcdb54&
function ShopUI(ui_data)
    if not ui_data then 
        ui_data = {
            isVisible = true,
            native_label = `CONSUMABLE_HERB_AMERICAN_GINSENG`,
            itemDescription = "Description",
            purchaseLabel = "Pay Now",
            purchasePrice = 1000,
            tokenPrice = 10, -- 0 for disable
            isGoldPrice = false,
            modifiedPriceVisible = true,
            purchaseModifiedPrice = 2000,
            modifiedPriceGold = false,
            ammoVisible = true,
            ammoCurrent = 1,
            ammoMax = 10,
            ammoTextureDictionary = "menu_textures",
            ammoTexture = "log_gang_bag",
            mailVisible = true,
            mailCurrent = 2,
        }
    end
    CloseUiappByHash(`SHOP_BROWSING`)
    Wait(200)
    local a = DatabindingAddDataContainerFromPath("", "DynamicCatalogItems")
    local b = {}
    b.cont = DatabindingAddDataContainer(a, "CatalogItemInspection")
    b.f_1 = DatabindingAddDataBool(b.cont, "isVisible", 1) 
    local str = false
    b.f_2 = DatabindingAddDataHash(b.cont, "itemLabel", ui_data.native_label)

    b.f_3 = DatabindingAddDataString(b.cont, "itemDescription", (ui_data.itemDescription or "Description"))
    b.f_4 = DatabindingAddDataString(b.cont, "purchaseLabel", (ui_data.purchaseLabel or "Label P"))
    b.f_5 = DatabindingAddDataInt(b.cont, "purchasePrice", (ui_data.purchasePrice or 1000))
    b.f_6 = DatabindingAddDataInt(b.cont, "tokenPrice", (ui_data.tokenPrice or 0))
    b.f_7 = DatabindingAddDataBool(b.cont, "isGoldPrice", (ui_data.isGoldPrice or false))
    b.f_8 = DatabindingAddDataInt(b.cont, "purchaseModifiedPrice", (ui_data.purchaseModifiedPrice or 2000))
    b.f_9 = DatabindingAddDataBool(b.cont, "modifiedPriceVisible", (ui_data.modifiedPriceVisible or false))
    b.f_10 = DatabindingAddDataBool(b.cont, "modifiedPriceGold", (ui_data.modifiedPriceGold or false))
    b.f_11 = DatabindingAddDataBool(b.cont, "ammoVisible", (ui_data.ammoVisible or false))
    b.f_12 = DatabindingAddDataInt(b.cont, "ammoCurrent", (ui_data.ammoCurrent or 1))
    b.f_13 = DatabindingAddDataInt(b.cont, "ammoMax", (ui_data.ammoMax or 5))
    b.f_14 = DatabindingAddDataString(b.cont, "ammoTextureDictionary", (ui_data.ammoTextureDictionary or "menu_textures"))
    b.f_15 = DatabindingAddDataString(b.cont, "ammoTexture", (ui_data.ammoTexture or "log_gang_bag"))
    b.f_19 = DatabindingAddDataInt(b.cont, "mailCurrent", (ui_data.mailCurrent or 3))
    b.f_20 = DatabindingAddDataBool(b.cont, "mailVisible", (ui_data.mailVisible or false))
    LaunchUiappByHashWithEntry(`SHOP_BROWSING`, -702860656)
    self = {
        container = b.cont,
        ui_data = ui_data,
        Update = function(newInfo)
            for i, v in pairs(newInfo) do
                ui_data[i] = v
                if i == "itemDescription" or i == "purchaseLabel" or i == "ammoTextureDictionary" or i == "ammoTexture" then 
                    DatabindingWriteDataStringFromParent(self.container, i, v)
                elseif i == "purchasePrice" or i == "tokenPrice" or i == "purchaseModifiedPrice" or i == "ammoCurrent" or i == "ammoMax" or i == "mailCurrent" then 
                    DatabindingWriteDataIntFromParent(self.container, i, v)
                elseif i == "isGoldPrice" or i == "modifiedPriceVisible" or i == "modifiedPriceGold" or i == "ammoVisible" or i == "mailVisible" then 
                    DatabindingWriteDataBoolFromParent(self.container, i, v)
                end
            end
            LaunchUiappByHashWithEntry(`SHOP_BROWSING`, -702860656) -- -649639953 -702860656
        end,
        Close = function()
            ui_data = {}
            CloseUiappByHash(`SHOP_BROWSING`)
        end
    }
    return self
end

RegisterCommand("testui", function(source, args, raw)
    local ui = ShopUI()
    Wait(2000)
    ui.Update({purchaseLabel ="Update L"})
    Wait(5000)
    ui.Close()
end, false)
