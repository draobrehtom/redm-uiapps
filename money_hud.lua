-- Ref: https://discord.com/channels/192358910387159041/643437814104457217/1210775778430689320

local menuContainer = DatabindingAddDataContainerFromPath('', 'Tithing')

local campCashContainer = DatabindingAddDataContainer(menuContainer, 'CampFunds')
DatabindingAddDataInt(campCashContainer, 'dollars', 69)
DatabindingAddDataInt(campCashContainer, 'cents', 69)
    
local cashContainer = DatabindingAddDataContainer(menuContainer, 'PlayerCash')
DatabindingAddDataInt(cashContainer, 'dollars', 420)
DatabindingAddDataInt(cashContainer, 'cents', 69)

EnableHudContext(1670279562)
