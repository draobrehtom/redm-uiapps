-- Ref: https://discord.com/channels/192358910387159041/643437814104457217/1242598171012628551
local RPGStatusIcons = DatabindingAddDataContainerFromPath("", "RPGStatusIcons")
local honorIcon = DatabindingAddDataContainer(RPGStatusIcons, "HonorIcon")
DatabindingAddDataInt(honorIcon, "State", 3) -- 1:lowest honor, 16:highest honor
