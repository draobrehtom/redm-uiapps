-- Ref: https://discord.com/channels/192358910387159041/643437867044962304/1257782902297464884

local passiveIcon = DatabindingAddDataContainerFromPath("","PassiveIcon")
local isVisible = DatabindingAddDataBool(passiveIcon,"isVisible",true)
local setState = DatabindingAddDataInt(passiveIcon, "setState", 1) -- max 3
