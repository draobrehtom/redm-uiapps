-- Ref: https://github.com/aaron1a12/wild/blob/9235aaa39696691ff26977ff1d2c18fe67971ef5/wild-core/client/cl_weaponWheel.lua#L80
local mpRankBar = DatabindingGetDataContainerFromPath("mp_rank_bar")
if mpRankBar == 0 then
    mpRankBar = DatabindingAddDataContainerFromPath("", "mp_rank_bar")
end

DatabindingAddDataString(mpRankBar, "rank_header_text", GetPlayerName(PlayerId()))
DatabindingAddDataString(mpRankBar, "rank_text", "1")
DatabindingAddDataFloat(mpRankBar, "xp_bar_minimum", 0.0)
DatabindingAddDataFloat(mpRankBar, "xp_bar_maximum", 100.0)
DatabindingAddDataFloat(mpRankBar, "xp_bar_value", 55.0)
