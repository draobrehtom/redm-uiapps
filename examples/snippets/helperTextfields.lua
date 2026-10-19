-- Ref: https://github.com/JamesSc0tt/RedM-Bottle-Shooting-Minigame/blob/main/game-bottleshoot/client/main-client.lua
local scoreboard_prompt = DatabindingAddDataContainerFromPath("", "helperTextfields");
DatabindingAddDataString(scoreboard_prompt, "rawLabel0", getLangString('game_hits'));
DatabindingAddDataString(scoreboard_prompt, "rawLabel1", getLangString('game_misses'));
DatabindingAddDataString(scoreboard_prompt, "rawValue0", tostring(system_config.game_data.counts.hits));
DatabindingAddDataString(scoreboard_prompt, "rawValue1", tostring(system_config.game_data.counts.misses));
Citizen.InvokeNative(0xC9CAEAEEC1256E54, -66088566)
